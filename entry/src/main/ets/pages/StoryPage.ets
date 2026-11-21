import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { GameStore } from '../domain/GameStore';
import { StoryEngine } from '../domain/StoryEngine';
import { SaveRepository } from '../data/SaveRepository';
import { StoryData, SceneInfo } from '../data/StoryData';
import { StoryNode, NodeResult } from '../model/Models';

@Entry
@Component
struct StoryPage {
  @StorageLink('sceneId') sceneId: string = 'S1';
  @StorageLink('phase') phase: number = 1;
  @StorageLink('clueIds') clueIds: string[] = [];
  @StorageLink('visited') visited: string[] = [];
  @StorageLink('flags') flags: Record<string, boolean> = {};
  @State body: string = '选择一处热点展开调查。未满足条件的节点会给出提示。';
  @State tip: string = '';
  @State saveTip: string = '';

  aboutToAppear(): void {
    GameStore.ensureInit();
  }

  async tapNode(node: StoryNode): Promise<void> {
    const result: NodeResult = GameStore.execNode(node);
    if (!result.ok) {
      this.tip = result.messages.join('  ');
      return;
    }
    this.body = node.body;
    this.tip = result.messages.length > 0 ? result.messages.join('  ') : '没有新的产出';
    const ctx = getContext(this) as common.UIAbilityContext;
    await SaveRepository.save(SaveRepository.AUTO_SLOT, GameStore.snapshot());
    this.saveTip = '进度已写入自动档';
    if (result.needDeduce) {
      router.pushUrl({ url: 'pages/DeductionPage' });
    }
  }

  @Builder
  SceneTab(scene: SceneInfo) {
    Column() {
      Text(scene.name)
        .fontSize(13)
        .fontColor(StoryEngine.sceneUnlocked(scene.id, this.flags) ? '#22283A' : '#A8A8A8')
        .fontWeight(this.sceneId === scene.id ? FontWeight.Bold : FontWeight.Normal)
      Text(StoryEngine.sceneUnlocked(scene.id, this.flags) ? scene.subtitle : '未解锁')
        .fontSize(10)
        .fontColor('#9A9A9A')
        .margin({ top: 2 })
        .maxLines(1)
    }
    .padding({ left: 10, right: 10, top: 8, bottom: 8 })
    .layoutWeight(1)
    .backgroundColor(this.sceneId === scene.id ? '#EFE5D2' : '#FFFFFF')
    .borderRadius(8)
    .onClick(() => {
      if (!StoryEngine.sceneUnlocked(scene.id, this.flags)) {
        this.tip = '该场景尚未解锁';
        return;
      }
      this.sceneId = scene.id;
      this.body = StoryData.sceneById(scene.id).name + '：' + StoryData.sceneById(scene.id).subtitle;
    })
  }

  @Builder
  HotspotCard(node: StoryNode) {
    Column() {
      Row() {
        Text(node.hotspot)
          .fontSize(15)
          .fontColor('#22283A')
          .fontWeight(FontWeight.Medium)
        Blank()
        Text(this.visited.includes(node.id) ? '已完成' : '可调查')
          .fontSize(11)
          .fontColor(this.visited.includes(node.id) ? '#8A8A8A' : '#8A6A2F')
      }
      .width('100%')

      Text(node.title)
        .fontSize(12)
        .fontColor('#6B6B6B')
        .margin({ top: 4 })

      if (!this.visited.includes(node.id) &&
        !StoryEngine.canEnter(node, this.clueIds, this.flags) && node.hint.length > 0) {
        Text(StoryEngine.missingReason(node, this.clueIds, this.flags))
          .fontSize(11)
          .fontColor('#B06A4A')
          .margin({ top: 6 })
      }
    }
    .padding(14)
    .width('100%')
    .backgroundColor(this.visited.includes(node.id) ? '#F7F4EE' : '#FFFFFF')
    .borderRadius(10)
    .border({ width: 1, color: '#E4DCCC' })
    .margin({ bottom: 10 })
    .onClick(() => {
      this.tapNode(node);
    })
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(14)
          .fontColor('#6B6B6B')
          .onClick(() => {
            router.back();
          })
        Blank()
        Text(StoryEngine.phaseLabel(this.phase) + ' · 线索 ' + this.clueIds.length + '/6')
          .fontSize(12)
          .fontColor('#8A6A2F')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12 })

      Row() {
        ForEach(StoryData.SCENES, (scene: SceneInfo) => {
          this.SceneTab(scene);
        }, (scene: SceneInfo) => scene.id)
      }
      .width('94%')
      .margin({ top: 10 })

      Column() {
        Text(this.body)
          .fontSize(14)
          .lineHeight(22)
          .fontColor('#22283A')
          .width('100%')
      }
      .padding(16)
      .width('94%')
      .backgroundColor('#FFFDF8')
      .borderRadius(12)
      .border({ width: 1, color: '#E6DCC8' })
      .margin({ top: 12 })

      if (this.tip.length > 0) {
        Text(this.tip)
          .fontSize(12)
          .fontColor('#8A6A2F')
          .width('94%')
          .margin({ top: 8 })
      }
      if (this.saveTip.length > 0) {
        Text(this.saveTip)
          .fontSize(10)
          .fontColor('#9A9A9A')
          .width('94%')
          .margin({ top: 4 })
      }

      Scroll() {
        Column() {
          ForEach(StoryData.nodesOfScene(this.sceneId), (node: StoryNode) => {
            this.HotspotCard(node);
          }, (node: StoryNode) => node.id)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .width('94%')
      .margin({ top: 12 })
      .scrollBar(BarState.Off)

      Row() {
        Button('打开线索板')
          .layoutWeight(1)
          .height(42)
          .backgroundColor('#22283A')
          .fontColor('#FFFFFF')
          .onClick(() => {
            router.pushUrl({ url: 'pages/ClueBoardPage' });
          })
        Button('存档管理')
          .layoutWeight(1)
          .height(42)
          .backgroundColor('#FFFFFF')
          .fontColor('#22283A')
          .border({ width: 1, color: '#D8D2C4' })
          .margin({ left: 10 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/ArchivePage' });
          })
      }
      .width('94%')
      .margin({ top: 8, bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F1EA')
  }
}
