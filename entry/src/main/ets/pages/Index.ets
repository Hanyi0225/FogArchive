import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { GameStore } from '../domain/GameStore';
import { StoryEngine } from '../domain/StoryEngine';
import { SaveRepository } from '../data/SaveRepository';
import { LoadResult } from '../model/Models';

@Entry
@Component
struct Index {
  @StorageLink('phase') phase: number = 1;
  @StorageLink('clueIds') clueIds: string[] = [];
  @StorageLink('visited') visited: string[] = [];
  @State tip: string = '';
  @State hasSave: boolean = false;

  aboutToAppear(): void {
    GameStore.ensureInit();
    const ctx = getContext(this) as common.UIAbilityContext;
    SaveRepository.load(SaveRepository.AUTO_SLOT).then((result: LoadResult) => {
      if (result.damaged) {
        this.tip = '存档异常：' + result.message + '，可重新开始';
        return;
      }
      if (result.snapshot.visited.length > 0) {
        GameStore.restore(result.snapshot);
        this.hasSave = true;
        this.tip = '已恢复上次进度（' + StoryEngine.phaseLabel(result.snapshot.phase) +
          '，线索 ' + result.snapshot.clueIds.length + ' 条）';
      }
    });
  }

  build() {
    Column() {
      Text('迷雾档案')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor('#22283A')
        .margin({ top: 48 })
      Text('三号楼最后一盏灯')
        .fontSize(15)
        .fontColor('#8A6A2F')
        .margin({ top: 6 })
      Text('校刊记者 · 独立调查')
        .fontSize(13)
        .fontColor('#6B6B6B')
        .margin({ top: 4 })

      Column() {
        Row() {
          Text('阶段')
            .fontSize(13)
            .fontColor('#6B6B6B')
          Blank()
          Text(StoryEngine.phaseLabel(this.phase))
            .fontSize(13)
            .fontColor('#22283A')
        }
        .width('100%')

        Progress({ value: this.clueIds.length, total: 6, type: ProgressType.Linear })
          .color('#8A6A2F')
          .width('100%')
          .margin({ top: 8 })

        Row() {
          Text('线索 ' + this.clueIds.length + ' / 6')
            .fontSize(13)
            .fontColor('#6B6B6B')
          Blank()
          Text('已探索节点 ' + this.visited.length + ' / 12')
            .fontSize(13)
            .fontColor('#6B6B6B')
        }
        .width('100%')
        .margin({ top: 6 })
      }
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .width('88%')
      .margin({ top: 28 })

      Button('继续调查')
        .width('88%')
        .height(48)
        .backgroundColor('#22283A')
        .fontColor('#FFFFFF')
        .margin({ top: 24 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/StoryPage' });
        })

      Row() {
        Button('线索板')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#FFFFFF')
          .fontColor('#22283A')
          .border({ width: 1, color: '#D8D2C4' })
          .onClick(() => {
            router.pushUrl({ url: 'pages/ClueBoardPage' });
          })
        Button('存档')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#FFFFFF')
          .fontColor('#22283A')
          .border({ width: 1, color: '#D8D2C4' })
          .margin({ left: 10 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/ArchivePage' });
          })
      }
      .width('88%')
      .margin({ top: 12 })

      Button('重新开始')
        .width('88%')
        .height(44)
        .backgroundColor('#F2ECE0')
        .fontColor('#7A5C2A')
        .margin({ top: 12 })
        .onClick(() => {
          GameStore.startNew();
          this.hasSave = false;
          this.tip = '已重置进度';
        })

      if (this.tip.length > 0) {
        Text(this.tip)
          .fontSize(12)
          .fontColor('#8A6A2F')
          .width('88%')
          .margin({ top: 16 })
      }

      Blank()

      Text('说明：关闭应用进程后重新打开，将自动读取自动档继续上次进度。')
        .fontSize(11)
        .fontColor('#9A9A9A')
        .width('88%')
        .margin({ bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F1EA')
  }
}
