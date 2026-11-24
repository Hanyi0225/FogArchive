import { describe, it, expect } from '@ohos/hypium';
import { StoryEngine } from '../main/ets/domain/StoryEngine';
import { ClueService } from '../main/ets/domain/ClueService';
import { DeductionService } from '../main/ets/domain/DeductionService';
import { Snapshot, ClueAddResult, LoadResult, StoryNode } from '../main/ets/model/Models';
import { StoryData } from '../main/ets/data/StoryData';

export default function storyTest() {
  describe('StoryEngineTest', () => {
    // 正常用例：持有 C1+C3 时，条件节点 N08 必须可进入，并产出“人为点灯”状态
    it('normal_shouldEnterConditionNode', 0, () => {
      const node: StoryNode = StoryData.nodeById('N08');
      const clueIds: string[] = ['C1', 'C3'];
      const flags: Record<string, boolean> = {};
      expect(StoryEngine.canEnter(node, clueIds, flags)).assertTrue();
      expect(node.addFlags.includes('artificial')).assertTrue();
    });

    // 边界用例：N12 门槛为 4 条线索，3 条不可进入、4 条恰好可进入
    it('boundary_deduceNeedFourClues', 0, () => {
      const node: StoryNode = StoryData.nodeById('N12');
      const flags: Record<string, boolean> = { 'artificial': true };
      const three: string[] = ['C1', 'C2', 'C3'];
      expect(StoryEngine.canEnter(node, three, flags)).assertFalse();
      const four: string[] = ['C1', 'C2', 'C3', 'C4'];
      expect(StoryEngine.canEnter(node, four, flags)).assertTrue();
      const reason: string = StoryEngine.missingReason(node, three, flags);
      expect(reason.includes('线索不足')).assertTrue();
    });

    // 异常用例：存档损坏与版本不匹配都不得抛异常，应返回空档并标记 damaged
    it('exception_damagedSnapshot', 0, () => {
      const broken: LoadResult = Snapshot.fromJson('not-a-json');
      expect(broken.damaged).assertTrue();
      expect(broken.snapshot.clueIds.length).assertEqual(0);

      const older: LoadResult = Snapshot.fromJson('{"version":2,"clueIds":["C1"]}');
      expect(older.damaged).assertTrue();
      expect(older.message.includes('版本不匹配')).assertTrue();
    });

    // 正常用例：线索收集幂等，重复收集不增加数量
    it('normal_addClueIsIdempotent', 0, () => {
      const first: ClueAddResult = ClueService.tryAdd([], 'C1');
      expect(first.added).assertTrue();
      expect(first.ids.length).assertEqual(1);
      const second: ClueAddResult = ClueService.tryAdd(first.ids, 'C1');
      expect(second.added).assertFalse();
      expect(second.ids.length).assertEqual(1);
    });

    // 异常用例：线索不全或指认错误时必须落到 E2，不能给出 E1
    it('exception_endingGuard', 0, () => {
      const flags: Record<string, boolean> = { 'artificial': true };
      const five: string[] = ['C1', 'C2', 'C3', 'C4', 'C5'];
      expect(DeductionService.judge(five, 'shen', flags) === 'E2').assertTrue();

      const six: string[] = ['C1', 'C2', 'C3', 'C4', 'C5', 'C6'];
      expect(DeductionService.judge(six, 'zhou', flags) === 'E2').assertTrue();
      expect(DeductionService.judge(six, 'shen', flags) === 'E1').assertTrue();

      // 未解锁推论时即使线索齐全也不能判定 E1
      const noFlag: Record<string, boolean> = {};
      expect(DeductionService.canDeduce(six, noFlag)).assertFalse();
    });

    // 边界用例：进入推理台的门槛为 4 条线索且已确认人为点灯，缺一不可
    it('boundary_canDeduceThreshold', 0, () => {
      const three: string[] = ['C1', 'C2', 'C3'];
      const four: string[] = ['C1', 'C2', 'C3', 'C4'];
      const flags: Record<string, boolean> = { 'artificial': true };
      expect(DeductionService.canDeduce(three, flags)).assertFalse();
      expect(DeductionService.canDeduce(four, flags)).assertTrue();
      expect(DeductionService.canDeduce(four, {})).assertFalse();
    });

    // 正常用例：结局理由分别列出线索缺口、指认不符与推论缺失，闭合时给出肯定结论
    it('normal_judgeReasonListsGaps', 0, () => {
      const five: string[] = ['C1', 'C2', 'C3', 'C4', 'C5'];
      expect(DeductionService.judgeReason(five, 'shen', { 'artificial': true }).includes('线索仅 5 条')).assertTrue();
      const six: string[] = ['C1', 'C2', 'C3', 'C4', 'C5', 'C6'];
      expect(DeductionService.judgeReason(six, 'zhou', { 'artificial': true }).includes('指认对象与档案记录不符')).assertTrue();
      expect(DeductionService.judgeReason(six, 'shen', {}).includes('人为点亮')).assertTrue();
      expect(DeductionService.judgeReason(six, 'shen', { 'artificial': true })).assertEqual('证据链闭合');
    });

    // 正常用例：空快照序列化后可无损恢复，不判为损坏档
    it('normal_blankSnapshotRoundTrip', 0, () => {
      const blank: Snapshot = Snapshot.blank();
      const text: string = blank.toJson();
      const result: LoadResult = Snapshot.fromJson(text);
      expect(result.damaged).assertFalse();
      expect(result.snapshot.clueIds.length).assertEqual(0);
      expect(result.snapshot.visited.length).assertEqual(0);
      expect(result.snapshot.version).assertEqual(1);
    });
  });
}
