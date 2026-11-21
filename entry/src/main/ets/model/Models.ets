/**
 * 领域数据模型：线索、剧情节点、存档快照及其结果对象。
 * 该文件只做数据承载，不含 UI 依赖，便于单元测试直接引用。
 */

export class Clue {
  id: string;
  title: string;
  sceneId: string;
  content: string;

  constructor(id: string, title: string, sceneId: string, content: string) {
    this.id = id;
    this.title = title;
    this.sceneId = sceneId;
    this.content = content;
  }
}

export class StoryNode {
  id: string;
  sceneId: string;
  title: string;
  hotspot: string;
  body: string;
  hint: string;
  requireClues: string[];
  requireFlags: string[];
  addClues: string[];
  addFlags: string[];
  setPhase: number;
  minClues: number;
  action: string;

  constructor(id: string, sceneId: string, title: string, hotspot: string, body: string,
              hint: string = '', requireClues: string[] = [], requireFlags: string[] = [],
              addClues: string[] = [], addFlags: string[] = [], setPhase: number = 0,
              minClues: number = 0, action: string = 'none') {
    this.id = id;
    this.sceneId = sceneId;
    this.title = title;
    this.hotspot = hotspot;
    this.body = body;
    this.hint = hint;
    this.requireClues = requireClues;
    this.requireFlags = requireFlags;
    this.addClues = addClues;
    this.addFlags = addFlags;
    this.setPhase = setPhase;
    this.minClues = minClues;
    this.action = action;
  }
}

export class Snapshot {
  version: number = 1;
  phase: number = 1;
  sceneId: string = 'S1';
  visited: string[] = [];
  clueIds: string[] = [];
  flags: Record<string, boolean> = {};
  endingId: string = '';
  savedAt: number = 0;

  toJson(): string {
    return JSON.stringify(this);
  }

  static blank(): Snapshot {
    return new Snapshot();
  }

  /**
   * 解析存档文本。版本不符、JSON 损坏、字段缺失一律判定为损坏档，
   * 返回空档并带 damaged 标记，调用方据此提示用户而不崩溃。
   */
  static fromJson(text: string): LoadResult {
    const result: LoadResult = new LoadResult(Snapshot.blank(), false, '');
    if (text.length === 0) {
      result.damaged = true;
      result.message = '存档内容为空';
      return result;
    }
    try {
      const parsed = JSON.parse(text) as Snapshot;
      if (parsed === null || parsed.version !== 1) {
        result.damaged = true;
        result.message = parsed === null ? '存档结构无效' : `存档版本不匹配：${parsed.version}`;
        return result;
      }
      if (parsed.clueIds === undefined || parsed.clueIds === null) {
        result.damaged = true;
        result.message = '存档缺少线索字段';
        return result;
      }
      const snap: Snapshot = new Snapshot();
      snap.version = parsed.version;
      snap.phase = parsed.phase > 0 ? parsed.phase : 1;
      snap.sceneId = parsed.sceneId === undefined || parsed.sceneId === null ? 'S1' : parsed.sceneId;
      snap.visited = parsed.visited === undefined || parsed.visited === null ? [] : parsed.visited;
      snap.clueIds = parsed.clueIds;
      snap.flags = parsed.flags === undefined || parsed.flags === null ? {} : parsed.flags;
      snap.endingId = parsed.endingId === undefined || parsed.endingId === null ? '' : parsed.endingId;
      snap.savedAt = parsed.savedAt === undefined ? 0 : parsed.savedAt;
      result.snapshot = snap;
      return result;
    } catch (err) {
      result.damaged = true;
      result.message = '存档解析失败';
      return result;
    }
  }
}

export class LoadResult {
  snapshot: Snapshot;
  damaged: boolean;
  message: string;

  constructor(snapshot: Snapshot, damaged: boolean, message: string) {
    this.snapshot = snapshot;
    this.damaged = damaged;
    this.message = message;
  }
}

export class ClueAddResult {
  added: boolean;
  ids: string[];
  message: string;

  constructor(added: boolean, ids: string[], message: string) {
    this.added = added;
    this.ids = ids;
    this.message = message;
  }
}

export class NodeResult {
  ok: boolean;
  messages: string[];
  needDeduce: boolean;

  constructor(ok: boolean, messages: string[], needDeduce: boolean) {
    this.ok = ok;
    this.messages = messages;
    this.needDeduce = needDeduce;
  }
}

export class SlotInfo {
  slotId: number;
  empty: boolean;
  phase: number;
  clueCount: number;
  savedAt: number;

  constructor(slotId: number, empty: boolean, phase: number, clueCount: number, savedAt: number) {
    this.slotId = slotId;
    this.empty = empty;
    this.phase = phase;
    this.clueCount = clueCount;
    this.savedAt = savedAt;
  }
}
