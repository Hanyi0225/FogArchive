/**
 * 推理与结局判定：结局不是选项直选，而是由“线索完整度 + 指认对象 + 推论状态”共同决定。
 */
import { StoryData } from '../data/StoryData';

export const ENDING_GOOD: string = 'E1';
export const ENDING_BAD: string = 'E2';
export const ACCUSED_SHEN: string = 'shen';

export class DeductionService {
  /**
   * 结局判定规则：
   * E1 需同时满足 6 条线索、指认沈明仪、持有“人为点灯”推论；
   * 否则一律 E2（线索不足、指认错误、未解锁推论）。
   */
  static judge(clueIds: string[], accusedId: string, flags: Record<string, boolean>): string {
    const allClues: boolean = clueIds.length >= 6;
    const rightPerson: boolean = accusedId === ACCUSED_SHEN;
    const unlocked: boolean = flags['artificial'] === true;
    if (allClues && rightPerson && unlocked) {
      return ENDING_GOOD;
    }
    return ENDING_BAD;
  }

  /** 提交前的门槛校验，未过门槛不允许进入指认环节 */
  static canDeduce(clueIds: string[], flags: Record<string, boolean>): boolean {
    return clueIds.length >= 4 && flags['artificial'] === true;
  }

  static judgeReason(clueIds: string[], accusedId: string, flags: Record<string, boolean>): string {
    const reasons: string[] = [];
    if (clueIds.length < 6) {
      reasons.push(`线索仅 ${clueIds.length} 条，未拼成完整证据链`);
    }
    if (accusedId !== ACCUSED_SHEN) {
      reasons.push('指认对象与档案记录不符');
    }
    if (flags['artificial'] !== true) {
      reasons.push('未能说明灯是人为点亮');
    }
    if (reasons.length === 0) {
      return '证据链闭合';
    }
    return reasons.join('；');
  }
}
