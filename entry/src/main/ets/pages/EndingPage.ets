import { router } from '@kit.ArkUI';
import { GameStore } from '../domain/GameStore';
import { StoryData } from '../data/StoryData';

@Entry
@Component
struct EndingPage {
  @StorageLink('endingId') endingId: string = '';
  @StorageLink('clueIds') clueIds: string[] = [];

  build() {
    Column() {
      Text(this.endingId === 'E1' ? '结局一' : '结局二')
        .fontSize(12)
        .fontColor('#8A6A2F')
        .margin({ top: 64 })

      Text(StoryData.endingById(this.endingId).title)
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor('#22283A')
        .margin({ top: 10 })

      Text('线索 ' + this.clueIds.length + ' / 6 · ' + (this.endingId === 'E1' ? '证据链闭合' : '证据链未闭合'))
        .fontSize(12)
        .fontColor('#6B6B6B')
        .margin({ top: 8 })

      Column() {
        Text(StoryData.endingById(this.endingId).body)
          .fontSize(14)
          .lineHeight(24)
          .fontColor('#22283A')
          .width('100%')
      }
      .padding(18)
      .width('88%')
      .backgroundColor('#FFFDF8')
      .borderRadius(12)
      .border({ width: 1, color: '#E6DCC8' })
      .margin({ top: 24 })

      Text(this.endingId === 'E1' ? '你确认了灯是人为点亮，并用借阅登记、装裱单与缺失的合影把名字钉死。'
        : '再走一遍三个场景，把 6 条线索补齐，并在窗台把“封楼通告 + 门锁划痕”串成人为点灯的推论。')
        .fontSize(12)
        .fontColor('#6B6B6B')
        .width('88%')
        .margin({ top: 16 })

      Blank()

      Button('重新调查')
        .width('88%')
        .height(46)
        .backgroundColor('#22283A')
        .fontColor('#FFFFFF')
        .onClick(() => {
          GameStore.startNew();
          router.replaceUrl({ url: 'pages/Index' });
        })

      Button('返回首页')
        .width('88%')
        .height(42)
        .backgroundColor('#FFFFFF')
        .fontColor('#22283A')
        .border({ width: 1, color: '#D8D2C4' })
        .margin({ top: 10, bottom: 28 })
        .onClick(() => {
          router.replaceUrl({ url: 'pages/Index' });
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F1EA')
  }
}
