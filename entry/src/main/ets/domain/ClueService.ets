/**
 * 线索服务：线索收集必须幂等，重复触发同一节点不会把线索数量刷高。
 */
import { ClueAddResult } from '../model/Models';
import { StoryData } from '../data/StoryData';

export class ClueService {
  static tryAdd(ids: string[], id: string): ClueAddResult {
    if (ids.includes(id)) {
      return new ClueAddResult(false, ids, '线索已存在，忽略重复收集');
    }
    const next: string[] = [];
    for (const v of ids) {
      next.push(v);
    }
    next.push(id);
    return new ClueAddResult(true, next, '已收集');
  }

  /** 线索板按场景分组时使用，返回该场景内的线索 */
  static listByScene(sceneId: string): string[] {
    const list: string[] = [];
    for (const c of StoryData.CLUES) {
      if (c.sceneId === sceneId) {
        list.push(c.id);
      }
    }
    return list;
  }

  static countOf(ids: string[]): number {
    return ids.length;
  }
}
