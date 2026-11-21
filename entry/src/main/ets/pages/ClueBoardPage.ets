import { router } from '@kit.ArkUI';
import { Clue } from '../model/Models';
import { StoryData } from '../data/StoryData';

@Entry
@Component
struct ClueBoardPage {
  @StorageLink('clueIds') clueIds: string[] = [];

  @Builder
  ClueCard(clue: Clue) {
    Column() {
      Row() {
        Text(clue.id)
          .fontSize(12)
          .fontColor('#FFFFFF')
          .backgroundColor(this.clueIds.includes(clue.id) ? '#8A6A2F' : '#BFB8AA')
          .borderRadius(4)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
        Text(clue.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.clueIds.includes(clue.id) ? '#22283A' : '#A8A8A8')
          .margin({ left: 8 })
        Blank()
        Text(this.clueIds.includes(clue.id) ? '已掌握' : '未发现')
          .fontSize(11)
          .fontColor(this.clueIds.includes(clue.id) ? '#8A6A2F' : '#B0B0B0')
      }
      .width('100%')

      Text(this.clueIds.includes(clue.id) ? clue.content : '继续调查以解锁这条线索。')
        .fontSize(12)
        .lineHeight(19)
        .fontColor(this.clueIds.includes(clue.id) ? '#4A4A4A' : '#B8B8B8')
        .width('100%')
        .margin({ top: 8 })
    }
    .padding(14)
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(10)
    .border({ width: 1, color: '#E4DCCC' })
    .margin({ bottom: 10 })
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
        Text('线索板 ' + this.clueIds.length + ' / 6')
          .fontSize(13)
          .fontColor('#8A6A2F')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12 })

      Text('六条线索分布在三个场景，缺少任意一条都无法拼成完整证据链。')
        .fontSize(12)
        .fontColor('#7A7A7A')
        .width('94%')
        .margin({ top: 8 })

      Scroll() {
        Column() {
          ForEach(StoryData.CLUES, (clue: Clue) => {
            this.ClueCard(clue);
          }, (clue: Clue) => clue.id)

          Text('已掌握线索也可在推理台作为指认依据。')
            .fontSize(11)
            .fontColor('#9A9A9A')
            .margin({ top: 8, bottom: 20 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .width('94%')
      .margin({ top: 10 })
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F1EA')
  }
}
