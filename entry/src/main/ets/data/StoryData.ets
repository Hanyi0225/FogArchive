/**
 * 静态剧情配置：6 条线索、3 个场景、12 个事件节点、2 个结局、3 名嫌疑人。
 * 节点、线索、场景的关系全部由这里定义，引擎只做条件判定，不硬编码剧情。
 */
import { Clue, StoryNode } from '../model/Models';

export class SceneInfo {
  id: string;
  name: string;
  subtitle: string;
  requireFlag: string;

  constructor(id: string, name: string, subtitle: string, requireFlag: string = '') {
    this.id = id;
    this.name = name;
    this.subtitle = subtitle;
    this.requireFlag = requireFlag;
  }
}

export class Ending {
  id: string;
  title: string;
  body: string;

  constructor(id: string, title: string, body: string) {
    this.id = id;
    this.title = title;
    this.body = body;
  }
}

export class Suspect {
  id: string;
  name: string;
  desc: string;

  constructor(id: string, name: string, desc: string) {
    this.id = id;
    this.name = name;
    this.desc = desc;
  }
}

export class StoryData {
  static readonly SCENES: SceneInfo[] = [
    new SceneInfo('S1', '一层大厅', '值班室 / 公告栏 / 配电室'),
    new SceneInfo('S2', '二层走廊', '403 教室门口 / 储物柜 / 窗台', 'gate'),
    new SceneInfo('S3', '校史馆档案室', '借阅登记 / 旧照片墙 / 档案柜', 'artificial')
  ];

  static readonly CLUES: Clue[] = [
    new Clue('C1', '封楼通告', 'S1', '通告落款是后勤保障处，封楼时间为五年前 4 月 17 日，原因写的是“配电线路老化”。'),
    new Clue('C2', '电表读数异常', 'S1', '配电室记录本显示 403 支路在近三周的凌晨 1 点至 3 点持续有 0.6 度用电。'),
    new Clue('C3', '403 门锁撬划痕', 'S2', '锁舌外侧有新划痕，方向由内向外，锁芯没有更换痕迹，像是有人持旧钥匙从里面开过。'),
    new Clue('C4', '2003 届纪念册', 'S2', '储物柜里有一本 2003 届毕业纪念册，扉页写着“沈明仪 赠”，夹层里压着一把旧钥匙。'),
    new Clue('C5', '借阅登记', 'S3', '登记簿最后一行是“2003 届毕业合影底片一套，借阅人沈明仪，事由：修补”。'),
    new Clue('C6', '缺失的合影', 'S3', '照片墙第三排空出一格，边框上残留胶痕，墙面有明显的重新装裱痕迹。')
  ];

  static readonly NODES: StoryNode[] = [
    new StoryNode('N01', 'S1', '接受调查', '与编辑部主任对话',
      '主任把匿名信推到你面前：三号楼封了五年，上周却有人看见 403 亮灯。你以校刊记者身份拿到了临时采访许可。',
      '', [], [], [], [], 2),

    new StoryNode('N02', 'S1', '值班室', '与保安老周交谈',
      '老周起初只肯说“看错了”。你把采访许可放在桌上，他沉默了一会儿，把门禁副卡推过来：别在楼里待太久。',
      '', [], [], [], ['gate'], 0),

    new StoryNode('N03', 'S1', '公告栏', '阅读封楼通告',
      '玻璃罩下的通告已经泛白，落款与日期还能辨认。你拍下照片，注意到“配电线路老化”这行字被红笔圈过。',
      '', [], [], ['C1'], [], 2),

    new StoryNode('N04', 'S1', '配电室', '抄录电表读数',
      '借着门禁卡打开配电室，记录本上 403 支路的凌晨读数被反复标注。这条线路本该在封楼时就断电。',
      '需要门禁权限。', [], ['gate'], ['C2'], [], 0),

    new StoryNode('N05', 'S2', '二层走廊', '循着灯光听声辨位',
      '走廊尽头只有 403 门缝透出一线光。你听见里面有人挪动木架，声音很轻，像怕惊动整栋楼。',
      '需要封楼通告，并已从保安处取得门禁。', ['C1'], ['gate'], [], [], 3),

    new StoryNode('N06', 'S2', '403 门锁', '观察锁舌与划痕',
      '锁舌外侧有新划痕，方向由内向外。你判断这不是撬门留下的痕迹，而是有人从里面开过门。',
      '需要先确认封楼通告。', ['C1'], [], ['C3'], [], 0),

    new StoryNode('N07', 'S2', '储物柜', '翻检旧储物柜',
      '柜门没有锁，里面只有一本纪念册和一把旧钥匙。扉页的赠书人名字，与你在公告栏见过的某个落款很像。',
      '需要先观察 403 门锁。', ['C3'], [], ['C4'], ['key'], 0),

    new StoryNode('N08', 'S2', '窗台', '比对粉笔灰与鞋印',
      '窗台积灰上有两道并排的半码鞋印，尺码偏小，鞋底花纹是校史馆值夜用的软底鞋。粉笔灰集中在窗沿内侧。',
      '需要同时掌握封楼通告与门锁划痕，才能把两条线索串起来。',
      ['C1', 'C3'], [], [], ['artificial'], 3),

    new StoryNode('N09', 'S3', '借阅登记', '查 2003 届底片去向',
      '登记簿最后一行写着：2003 届毕业合影底片一套，借阅人沈明仪，事由“修补”。日期正是亮灯的第一天。',
      '需要先确认灯是人为点亮的。', [], ['artificial'], ['C5'], [], 0),

    new StoryNode('N10', 'S3', '旧照片墙', '查看缺失的合影',
      '第三排空出一格，边框留着胶痕。旁边补拍的新照片里，有两个同学的名字被重新标注过。',
      '需要先查到借阅登记。', ['C5'], [], ['C6'], [], 0),

    new StoryNode('N11', 'S3', '档案柜', '核对装裱记录',
      '档案柜里的装裱单显示，缺失的合影在两周前被取出返修，经手人签字与借阅登记完全一致。',
      '需要借阅登记与照片墙两条线索互证。', ['C5', 'C6'], [], [], ['proved'], 0),

    new StoryNode('N12', 'S3', '推理台', '提交最终判断',
      '线索板已经钉满。编辑部只等一个名字，以及一句能站得住脚的说明。',
      '需要至少 4 条线索，并已确认灯是人为点亮。', [], ['artificial'], [], [], 4, 4, 'deduce')
  ];

  static readonly ENDINGS: Ending[] = [
    new Ending('E1', '迟到的合影',
      '你写下沈明仪的名字。她在校史馆等了很久，说那届合影上有两个同学的名字被涂改过，她想在自己还记得的时候把名字补回去。\n' +
      '稿件刊发那天，封楼公告撤下，403 的灯换成了常亮的走廊灯。照片墙补回了那张合影，边框下面多了一行小字：修补人 沈明仪。'),
    new Ending('E2', '封楼的回声',
      '你把报告交上去，证据之间的缝隙没有补齐。编辑部退回了稿件，理由是“无法证实有人进入”。\n' +
      '三号楼的灯又亮了几晚，随后彻底熄灭。封条重新贴上，档案室那本借阅登记被收回，故事停在这里。')
  ];

  static readonly SUSPECTS: Suspect[] = [
    new Suspect('shen', '沈明仪', '校史馆退休管理员，五年前负责封楼交接。'),
    new Suspect('zhou', '保安老周', '封楼后仍持有门禁副卡，是第一个报告亮灯的人。'),
    new Suspect('outsider', '校外人员', '附近工地夜间施工人员，无校内记录。')
  ];

  static clueById(id: string): Clue {
    for (const c of StoryData.CLUES) {
      if (c.id === id) {
        return c;
      }
    }
    return new Clue('', '未知线索', '', '');
  }

  static nodeById(id: string): StoryNode {
    for (const n of StoryData.NODES) {
      if (n.id === id) {
        return n;
      }
    }
    return StoryData.NODES[0];
  }

  static nodesOfScene(sceneId: string): StoryNode[] {
    const list: StoryNode[] = [];
    for (const n of StoryData.NODES) {
      if (n.sceneId === sceneId) {
        list.push(n);
      }
    }
    return list;
  }

  static endingById(id: string): Ending {
    for (const e of StoryData.ENDINGS) {
      if (e.id === id) {
        return e;
      }
    }
    return StoryData.ENDINGS[1];
  }

  static sceneById(id: string): SceneInfo {
    for (const s of StoryData.SCENES) {
      if (s.id === id) {
        return s;
      }
    }
    return StoryData.SCENES[0];
  }

  /** 启动自检：节点 id 唯一、线索引用存在、每个场景至少 3 个节点、总数满足要求。 */
  static validate(): string[] {
    const problems: string[] = [];
    const ids: string[] = [];
    for (const n of StoryData.NODES) {
      if (ids.includes(n.id)) {
        problems.push(`节点 id 重复：${n.id}`);
      }
      ids.push(n.id);
      for (const c of n.addClues) {
        if (StoryData.clueById(c).id === '') {
          problems.push(`节点 ${n.id} 引用了不存在的线索 ${c}`);
        }
      }
    }
    for (const s of StoryData.SCENES) {
      if (StoryData.nodesOfScene(s.id).length < 3) {
        problems.push(`场景 ${s.id} 节点不足 3 个`);
      }
    }
    if (StoryData.NODES.length !== 12) {
      problems.push(`节点数量为 ${StoryData.NODES.length}，要求 12`);
    }
    if (StoryData.CLUES.length !== 6) {
      problems.push(`线索数量为 ${StoryData.CLUES.length}，要求 6`);
    }
    return problems;
  }
}
