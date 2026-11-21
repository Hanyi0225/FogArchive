/**
 * 剧情引擎：只做可进入判定与提示生成，不修改任何状态，便于单元测试。
 */
import { StoryNode } from '../model/Models';
import { StoryData } from '../data/StoryData';

export class StoryEngine {
  /** 节点可进入 = 必需线索全持有 + 必需状态全为 true + 线索总数达到门槛 */
  static canEnter(node: StoryNode, clueIds: string[], flags: Record<string, boolean>): boolean {
    for (const c of node.requireClues) {
      if (!clueIds.includes(c)) {
        return false;
      }
    }
    for (const f of node.requireFlags) {
      if (flags[f] !== true) {
        return false;
      }
    }
    if (node.minClues > 0 && clueIds.length < node.minClues) {
      return false;
    }
    return true;
  }

  /** 未满足条件时给玩家一句能看懂的提示，而不是直接置灰不说话 */
  static missingReason(node: StoryNode, clueIds: string[], flags: Record<string, boolean>): string {
    const parts: string[] = [];
    const missingClues: string[] = [];
    for (const c of node.requireClues) {
      if (!clueIds.includes(c)) {
        missingClues.push(StoryData.clueById(c).title);
      }
    }
    if (missingClues.length > 0) {
      parts.push('还缺线索：' + missingClues.join('、'));
    }
    const missingFlags: string[] = [];
    for (const f of node.requireFlags) {
      if (flags[f] !== true) {
        missingFlags.push(StoryEngine.flagLabel(f));
      }
    }
    if (missingFlags.length > 0) {
      parts.push('还缺状态：' + missingFlags.join('、'));
    }
    if (node.minClues > 0 && clueIds.length < node.minClues) {
      parts.push(`线索不足：当前 ${clueIds.length} 条，需要 ${node.minClues} 条`);
    }
    if (parts.length === 0) {
      return node.hint;
    }
    return parts.join('；') + (node.hint.length > 0 ? '。' + node.hint : '');
  }

  /** 场景解锁：S2 需要门禁状态，S3 需要“人为点灯”推论 */
  static sceneUnlocked(sceneId: string, flags: Record<string, boolean>): boolean {
    const scene = StoryData.sceneById(sceneId);
    if (scene.requireFlag.length === 0) {
      return true;
    }
    return flags[scene.requireFlag] === true;
  }

  /** 当前场景尚未完成且可进入的热点 */
  static availableNodes(sceneId: string, visited: string[], clueIds: string[],
                        flags: Record<string, boolean>): StoryNode[] {
    const list: StoryNode[] = [];
    for (const n of StoryData.nodesOfScene(sceneId)) {
      if (!visited.includes(n.id) && StoryEngine.canEnter(n, clueIds, flags)) {
        list.push(n);
      }
    }
    return list;
  }

  static flagLabel(flag: string): string {
    if (flag === 'gate') {
      return '门禁权限';
    }
    if (flag === 'key') {
      return '旧钥匙';
    }
    if (flag === 'artificial') {
      return '人为点灯推论';
    }
    if (flag === 'proved') {
      return '装裱互证';
    }
    return flag;
  }

  static phaseLabel(phase: number): string {
    if (phase === 1) {
      return '接受调查';
    }
    if (phase === 2) {
      return '搜集线索';
    }
    if (phase === 3) {
      return '验证推理';
    }
    if (phase === 4) {
      return '作出判断';
    }
    if (phase === 5) {
      return '结局';
    }
    return '未知阶段';
  }
}
