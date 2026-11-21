/**
 * 偏好存储：Preferences 只放轻量界面偏好（上次使用的档位、是否开启阅读提示），
 * 与 RDB 中的业务快照分开，避免频繁写库。
 */
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

const PREF_NAME: string = 'fog_prefs';
const KEY_LAST_SLOT: string = 'lastSlot';
const KEY_HINT_ON: string = 'hintOn';

export class PrefsStore {
  private static prefs: preferences.Preferences | undefined = undefined;

  static async init(context: common.UIAbilityContext): Promise<void> {
    PrefsStore.prefs = await preferences.getPreferences(context, PREF_NAME);
  }

  private static async ensure(): Promise<preferences.Preferences | undefined> {
    return PrefsStore.prefs;
  }

  static async setLastSlot(context: common.UIAbilityContext, slotId: number): Promise<void> {
    let store: preferences.Preferences | undefined = await PrefsStore.ensure();
    if (store === undefined) {
      await PrefsStore.init(context);
      store = PrefsStore.prefs;
    }
    if (store === undefined) {
      return;
    }
    await store.put(KEY_LAST_SLOT, slotId);
    await store.flush();
  }

  static async getLastSlot(context: common.UIAbilityContext): Promise<number> {
    let store: preferences.Preferences | undefined = await PrefsStore.ensure();
    if (store === undefined) {
      await PrefsStore.init(context);
      store = PrefsStore.prefs;
    }
    if (store === undefined) {
      return 1;
    }
    const value: preferences.ValueType = await store.get(KEY_LAST_SLOT, 1);
    return typeof value === 'number' ? value : 1;
  }

  static async setHintOn(context: common.UIAbilityContext, on: boolean): Promise<void> {
    let store: preferences.Preferences | undefined = await PrefsStore.ensure();
    if (store === undefined) {
      await PrefsStore.init(context);
      store = PrefsStore.prefs;
    }
    if (store === undefined) {
      return;
    }
    await store.put(KEY_HINT_ON, on);
    await store.flush();
  }

  static async isHintOn(context: common.UIAbilityContext): Promise<boolean> {
    let store: preferences.Preferences | undefined = await PrefsStore.ensure();
    if (store === undefined) {
      await PrefsStore.init(context);
      store = PrefsStore.prefs;
    }
    if (store === undefined) {
      return true;
    }
    const value: preferences.ValueType = await store.get(KEY_HINT_ON, true);
    return typeof value === 'boolean' ? value : true;
  }
}
