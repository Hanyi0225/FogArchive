/**
 * 存档仓库：使用 RDB（relationalStore）保存 3 个档位的进度快照。
 * 每次推进节点写入自动档（1 号），手动档（2、3 号）由存档页写入。
 * 读取时统一走 Snapshot.fromJson 做版本与结构校验，损坏档不抛异常。
 */
import { relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { LoadResult, Snapshot, SlotInfo } from '../model/Models';

const DOMAIN: number = 0x0001;
const TAG: string = 'FogArchive';
const TABLE: string = 'save_slot';
const CREATE_SQL: string =
  'CREATE TABLE IF NOT EXISTS save_slot (slot INTEGER PRIMARY KEY, version INTEGER NOT NULL, payload TEXT NOT NULL, saved_at INTEGER NOT NULL)';

export class SaveRepository {
  static readonly SLOT_COUNT: number = 3;
  static readonly AUTO_SLOT: number = 1;
  private static store: relationalStore.RdbStore | undefined = undefined;
  private static ready: Promise<void> | undefined = undefined;

  static init(context: common.UIAbilityContext): Promise<void> {
    if (SaveRepository.ready !== undefined) {
      return SaveRepository.ready;
    }
    SaveRepository.ready = SaveRepository.doInit(context);
    return SaveRepository.ready;
  }

  private static async doInit(context: common.UIAbilityContext): Promise<void> {
    const config: relationalStore.StoreConfig = {
      name: 'fog.db',
      securityLevel: relationalStore.SecurityLevel.S1
    };
    const store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, config);
    await store.executeSql(CREATE_SQL);
    SaveRepository.store = store;
    hilog.info(DOMAIN, TAG, 'rdb ready, table=%{public}s', TABLE);
  }

  private static async ensureReady(): Promise<void> {
    if (SaveRepository.ready !== undefined) {
      await SaveRepository.ready;
    }
  }

  static async save(slotId: number, snap: Snapshot): Promise<void> {
    await SaveRepository.ensureReady();
    const store: relationalStore.RdbStore | undefined = SaveRepository.store;
    if (store === undefined) {
      hilog.error(DOMAIN, TAG, 'save failed: store not ready');
      return;
    }
    const values: relationalStore.ValuesBucket = {
      'slot': slotId,
      'version': snap.version,
      'payload': snap.toJson(),
      'saved_at': snap.savedAt
    };
    await store.insert(TABLE, values, relationalStore.ConflictResolution.ON_CONFLICT_REPLACE);
    hilog.info(DOMAIN, TAG, 'saved slot=%{public}d', slotId);
  }

  static async load(slotId: number): Promise<LoadResult> {
    await SaveRepository.ensureReady();
    const store: relationalStore.RdbStore | undefined = SaveRepository.store;
    if (store === undefined) {
      return new LoadResult(Snapshot.blank(), true, '数据库未初始化');
    }
    const rs: relationalStore.ResultSet =
      await store.querySql('SELECT payload FROM save_slot WHERE slot = ?', [slotId]);
    try {
      if (rs.goToNextRow()) {
        const payload: string = rs.getString(rs.getColumnIndex('payload'));
        return Snapshot.fromJson(payload);
      }
    } finally {
      rs.close();
    }
    return new LoadResult(Snapshot.blank(), false, '该档位为空');
  }

  static async clear(slotId: number): Promise<void> {
    await SaveRepository.ensureReady();
    const store: relationalStore.RdbStore | undefined = SaveRepository.store;
    if (store === undefined) {
      return;
    }
    await store.executeSql('DELETE FROM save_slot WHERE slot = ?', [slotId]);
  }

  static async listSlots(): Promise<SlotInfo[]> {
    await SaveRepository.ensureReady();
    const list: SlotInfo[] = [];
    for (let i = 1; i <= SaveRepository.SLOT_COUNT; i++) {
      const loaded: LoadResult = await SaveRepository.load(i);
      const empty: boolean = loaded.message === '该档位为空' || loaded.snapshot.visited.length === 0;
      list.push(new SlotInfo(i, empty, loaded.snapshot.phase, loaded.snapshot.clueIds.length,
        loaded.snapshot.savedAt));
    }
    return list;
  }
}
