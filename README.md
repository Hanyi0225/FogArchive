# 迷雾档案：三号楼最后一盏灯

《鸿蒙高级应用开发工程师认证》期末大作业 · 主题一「迷雾档案——校园线索推理与多结局探索 App」
独立完成 · HarmonyOS 5.0.5（API 17）· ArkTS + ArkUI

## 一、作品简介

玩家以校刊学生记者身份调查“封楼五年的三号教学楼深夜亮灯”事件。三个场景中分布 12 个事件节点、6 条线索，线索与状态共同决定节点能否进入；线索齐全并指认正确才进入结局一，否则进入结局二。每次推进节点自动落盘，杀进程后重开自动恢复。

## 二、功能对照（选题硬指标）

| 选题要求 | 本工程实现 |
| --- | --- |
| 至少 3 个可探索场景 | S1 一层大厅、S2 二层走廊、S3 校史馆档案室（S2 需 gate、S3 需 artificial） |
| 12 个有意义的事件节点 | N01—N12，见 `entry/src/main/ets/data/StoryData.ets` |
| 6 条可查阅线索 | C1—C6，线索板可查阅已掌握线索全文 |
| 线索与选择真实改变后续 | N08 需 C1+C3 交叉；N09、N12 需 artificial；N12 需线索 ≥4 |
| 2 个由不同条件触发的结局 | E1《迟到的合影》/ E2《封楼的回声》，由 `DeductionService.judge` 计算 |
| 线索板、关键状态提示、阶段进度 | ClueBoardPage、节点缺项提示、首页与叙事页的阶段/进度条 |
| 存档与重开、杀进程恢复 | RDB 三档位（1 号自动档 + 2 个手动档），Preferences 记录上次档位 |
| 业务数据建模、Preferences/RDB、单元测试 | Models / SaveRepository / PrefsStore / `entry/src/test` 8 条用例 |

## 三、目录结构

```
FogArchive/
├── AppScope/app.json5                    应用级配置（bundleName、图标）
├── build-profile.json5                   编译配置（compatibleSdkVersion 5.0.5(17)）
├── hvigorfile.ts / oh-package.json5      构建脚本与依赖
├── _tools/                               开发辅助脚本（项目自检、图标生成，不参与编译与打包）
├── docs/                                 软件需求说明书、运行截图与演示录屏
└── entry/
    ├── src/main/
    │   ├── module.json5                  模块配置（EntryAbility、页面清单）
    │   ├── ets/
    │   │   ├── entryability/EntryAbility.ets   启动时初始化 RDB、Preferences、剧情自检
    │   │   ├── model/Models.ets                线索、节点、存档快照、结果对象
    │   │   ├── data/StoryData.ets              6 线索 / 12 节点 / 2 结局 / 3 嫌疑人
    │   │   ├── data/SaveRepository.ets         RDB 存档读写与损坏档处理
    │   │   ├── data/PrefsStore.ets             Preferences 偏好
    │   │   ├── domain/StoryEngine.ets          节点可进入判定与提示
    │   │   ├── domain/ClueService.ets          线索幂等收集
    │   │   ├── domain/DeductionService.ets     结局判定与门槛校验
    │   │   ├── domain/GameStore.ets            AppStorage 全局状态与节点执行
    │   │   └── pages/                          Index / Story / ClueBoard / Deduction / Archive / Ending
    │   └── resources/base/                    字符串、颜色、页面清单、图标
    └── src/test/                              本地单元测试（8 条）
```

## 四、开发环境

- DevEco Studio 5.0.13.230（Stage 模型）
- SDK：HarmonyOS 5.0.5（API 17），`compatibleSdkVersion` 为 `5.0.5(17)`
- 构建工具：hvigor 5.17.5、ohpm、Node.js 18.20.1
- 设备：Phone 模拟器或真机（API 17）

## 五、运行方法

1. DevEco Studio → File → Open，选择 `FogArchive` 目录。
2. 首次打开会提示 Sync，等待依赖下载完成（需联网）。
3. File → Project Structure → Signing Configs，勾选 Automatically generate signature（需登录华为账号）。
4. 选择 `entry` 模块与模拟器/真机，点击 Run。
5. 验证“杀进程恢复”：进入叙事页完成若干节点 → 从最近任务列表上滑杀掉应用 → 重新打开 → 首页提示“已恢复上次进度（阶段，线索 n 条）”。

## 六、单元测试

`entry/src/test/` 下为本地单元测试（hypium）：

- 在 DevEco Studio 中右键 `entry/src/test` → Run，或在工程根目录执行
  `node <DevEco>/tools/hvigor/bin/hvigorw.js --mode module -p product=default -p module=entry@default test --no-daemon`。
- 8 条用例与覆盖类型：
  1. `normal_shouldEnterConditionNode`：正常，C1+C3 → N08 可进入
  2. `boundary_deduceNeedFourClues`：边界，3 条不可进入、4 条恰好可进入
  3. `exception_damagedSnapshot`：异常，损坏 JSON 与版本不符均回退空档
  4. `normal_addClueIsIdempotent`：正常，重复收集不增加线索数
  5. `exception_endingGuard`：异常，线索不全/指认错误一律 E2
  6. `boundary_canDeduceThreshold`：边界，推理台门槛为 4 条线索且需 artificial，缺一不可
  7. `normal_judgeReasonListsGaps`：正常，结局理由分别列出线索缺口、指认不符与推论缺失
  8. `normal_blankSnapshotRoundTrip`：正常，空快照序列化后可无损恢复，不判为损坏档
- 实测结果：8 条用例在 DevEco Studio 右键 Run 后全部通过（共 8 个测试，16 毫秒）；覆盖率报告行覆盖率 27.4%、函数覆盖率 27.4%，未覆盖部分主要为页面层与 RDB 读写分支。

## 七、提交记录（与报告表 4.1 对应）

| 短哈希 | 提交说明 |
| --- | --- |
| d378acf | init: 创建 FogArchive 工程，接入 EntryAbility 与 RDB/Preferences 初始化 |
| 97b755e | feat(story): 沉淀 3 场景 12 节点 6 线索 2 结局的剧情配置与启动自检 |
| a801a48 | feat(engine): 实现节点可进入判定与缺项提示，补充场景解锁规则 |
| 3b1e469 | feat(state): 节点执行、线索收集幂等、每次推进写入自动档 |
| fe92285 | feat(save): 三档位存档、损坏档保护与页面实现 |
| 43bac52 | feat(test): 补全 README、运行截图、图标与 5 条 hypium 用例 |
| 7e2ee78 | feat(test): 补充推理门槛、结局理由与空快照往返用例，README 增补 E2 截图与辅助脚本说明 |
| 595abed | docs: 回填提交记录哈希，补充需求说明书与 README 口径 |

## 八、运行截图

首页、场景、线索板、推理台、结局页与存档页的实际运行截图，以及架构图与流程图，见 [`docs/screenshots`](docs/screenshots)：

| 截图 | 文件 |
| --- | --- |
| 首页（线索 0/6、节点 0/12） | `docs/screenshots/01-home-initial.png` |
| 场景页三种卡片状态 | `docs/screenshots/02-scene-states.png` |
| 线索板（线索 4/6） | `docs/screenshots/03-clue-board.png` |
| 推理台（线索 6/6） | `docs/screenshots/04-deduction.png` |
| 结局 E1《迟到的合影》 | `docs/screenshots/05-ending-e1.png` |
| 结局 E2《封楼的回声》 | `docs/screenshots/09-ending-e2.png` |
| 存档页三档位 | `docs/screenshots/06-archive.png` |
| 系统架构图 | `docs/screenshots/07-architecture.png` |
| 模块业务流程图 | `docs/screenshots/08-flow.png` |

## 九、演示录屏

演示视频：`docs/demo.mp4`（待录制补充）。

录制路径：启动应用 → 首页「继续调查」→ 在一层大厅、二层走廊收集线索 → 进入推理台指认嫌疑人 → 进入对应结局 → 从最近任务列表结束应用进程后重新打开，验证进度恢复到上次场景与线索。

## 十、已知限制

- 剧情为静态配置，不接在线服务；音效与插图未接入，界面为纯 ArkUI 排版。
- 指认对象为固定三人，未做自由文本输入。
- 本地单元测试覆盖领域层纯函数，RDB 读写需在设备上手动验证（见运行方法第 5 步）。
