/**
 * 全局状态仓库：进度以 AppStorage 承载，页面通过 @StorageLink 订阅更新，
 * 任何一次推进都同步落盘到 RDB 第 1 档位（自动档），实现杀进程后恢复。
 */
import { NodeResult, Snapshot } from '../model/Models';
import { StoryData } from '../data/StoryData';
import { StoryEngine } from './StoryEngine';
import { ClueService } from './ClueService';
import { StoryNode } from '../model/Models';

export const KEY_PHASE: string = 'phase';
export const KEY_SCENE: string = 'sceneId';
export const KEY_VISITED: string = 'visited';
export const KEY_CLUES: string = 'clueIds';
export const KEY_FLAGS: string = 'flags';
export const KEY_ENDING: string = 'endingId';
export const KEY_TIP: string = 'tip';

export class GameStore {
  static ensureInit(): void {
    if (AppStorage.get<number>(KEY_PHASE) === undefined) {
      AppStorage.setOrCreate<number>(KEY_PHASE, 1);
    }
    if (AppStorage.get<string>(KEY_SCENE) === undefined) {
      AppStorage.setOrCreate<string>(KEY_SCENE, 'S1');
    }
    if (AppStorage.get<string[]>(KEY_VISITED) === undefined) {
      AppStorage.setOrCreate<string[]>(KEY_VISITED, []);
    }
    if (AppStorage.get<string[]>(KEY_CLUES) === undefined) {
      AppStorage.setOrCreate<string[]>(KEY_CLUES, []);
    }
    const flags: Record<string, boolean> = {};
    if (AppStorage.get<Record<string, boolean>>(KEY_FLAGS) === undefined) {
      AppStorage.setOrCreate<Record<string, boolean>>(KEY_FLAGS, flags);
    }
    if (AppStorage.get<string>(KEY_ENDING) === undefined) {
      AppStorage.setOrCreate<string>(KEY_ENDING, '');
    }
    if (AppStorage.get<string>(KEY_TIP) === undefined) {
      AppStorage.setOrCreate<string>(KEY_TIP, '');
    }
  }

  static phase(): number {
    const v: number | undefined = AppStorage.get<number>(KEY_PHASE);
    return v === undefined ? 1 : v;
  }

  static sceneId(): string {
    const v: string | undefined = AppStorage.get<string>(KEY_SCENE);
    return v === undefined ? 'S1' : v;
  }

  static visited(): string[] {
    const v: string[] | undefined = AppStorage.get<string[]>(KEY_VISITED);
    return v === undefined ? [] : v;
  }

  static clueIds(): string[] {
    const v: string[] | undefined = AppStorage.get<string[]>(KEY_CLUES);
    return v === undefined ? [] : v;
  }

  static flags(): Record<string, boolean> {
    const v: Record<string, boolean> | undefined = AppStorage.get<Record<string, boolean>>(KEY_FLAGS);
    return v === undefined ? {} : v;
  }

  static endingId(): string {
    const v: string | undefined = AppStorage.get<string>(KEY_ENDING);
    return v === undefined ? '' : v;
  }

  /** 开始新游戏：清空进度，回到阶段 1 */
  static startNew(): void {
    AppStorage.setOrCreate<number>(KEY_PHASE, 1);
    AppStorage.setOrCreate<string>(KEY_SCENE, 'S1');
    AppStorage.setOrCreate<string[]>(KEY_VISITED, []);
    AppStorage.setOrCreate<string[]>(KEY_CLUES, []);
    const flags: Record<string, boolean> = {};
    AppStorage.setOrCreate<Record<string, boolean>>(KEY_FLAGS, flags);
    AppStorage.setOrCreate<string>(KEY_ENDING, '');
    AppStorage.setOrCreate<string>(KEY_TIP, '');
  }

  /** 从存档恢复：整体覆盖 AppStorage 中的业务状态 */
  static restore(snap: Snapshot): void {
    AppStorage.setOrCreate<number>(KEY_PHASE, snap.phase);
    AppStorage.setOrCreate<string>(KEY_SCENE, snap.sceneId);
    AppStorage.setOrCreate<string[]>(KEY_VISITED, snap.visited);
    AppStorage.setOrCreate<string[]>(KEY_CLUES, snap.clueIds);
    AppStorage.setOrCreate<Record<string, boolean>>(KEY_FLAGS, snap.flags);
    AppStorage.setOrCreate<string>(KEY_ENDING, snap.endingId);
  }

  static snapshot(): Snapshot {
    const snap: Snapshot = new Snapshot();
    snap.phase = GameStore.phase();
    snap.sceneId = GameStore.sceneId();
    snap.visited = GameStore.visited();
    snap.clueIds = GameStore.clueIds();
    snap.flags = GameStore.flags();
    snap.endingId = GameStore.endingId();
    snap.savedAt = Date.now();
    return snap;
  }

  /** 执行节点：条件校验 → 产出线索与状态 → 推进阶段与场景 */
  static execNode(node: StoryNode): NodeResult {
    const clueIds: string[] = GameStore.clueIds();
    const flags: Record<string, boolean> = GameStore.flags();
    if (!StoryEngine.canEnter(node, clueIds, flags)) {
      return new NodeResult(false, [StoryEngine.missingReason(node, clueIds, flags)], false);
    }

    const messages: string[] = [];
    let nextClues: string[] = clueIds;
    for (const cid of node.addClues) {
      const added = ClueService.tryAdd(nextClues, cid);
      nextClues = added.ids;
      if (added.added) {
        messages.push('获得线索：' + StoryData.clueById(cid).title);
      }
    }

    const nextFlags: Record<string, boolean> = {};
    for (const k of Object.keys(flags)) {
      nextFlags[k] = flags[k];
    }
    for (const f of node.addFlags) {
      if (nextFlags[f] !== true) {
        messages.push('解锁状态：' + StoryEngine.flagLabel(f));
      }
      nextFlags[f] = true;
    }

    const nextVisited: string[] = [];
    for (const v of GameStore.visited()) {
      nextVisited.push(v);
    }
    if (!nextVisited.includes(node.id)) {
      nextVisited.push(node.id);
    }

    AppStorage.setOrCreate<string[]>(KEY_CLUES, nextClues);
    AppStorage.setOrCreate<Record<string, boolean>>(KEY_FLAGS, nextFlags);
    AppStorage.setOrCreate<string[]>(KEY_VISITED, nextVisited);
    AppStorage.setOrCreate<string>(KEY_SCENE, node.sceneId);
    if (node.setPhase > 0) {
      AppStorage.setOrCreate<number>(KEY_PHASE, node.setPhase);
    }
    AppStorage.setOrCreate<string>(KEY_TIP, messages.join('  '));

    return new NodeResult(true, messages, node.action === 'deduce');
  }

  /** 写入结局：阶段推进到 5，并记录结局编号 */
  static finish(endingId: string): void {
    AppStorage.setOrCreate<number>(KEY_PHASE, 5);
    AppStorage.setOrCreate<string>(KEY_ENDING, endingId);
  }
}
