import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { DeductionService } from '../domain/DeductionService';
import { GameStore } from '../domain/GameStore';
import { SaveRepository } from '../data/SaveRepository';
import { PrefsStore } from '../data/PrefsStore';
import { StoryData, Suspect } from '../data/StoryData';

@Entry
@Component
struct DeductionPage {
  @StorageLink('clueIds') clueIds: string[] = [];
  @StorageLink('flags') flags: Record<string, boolean> = {};
  @State selected: string = '';
  @State tip: string = '';

  @Builder
  SuspectCard(item: Suspect) {
    Column() {
      Row() {
        Text(item.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#22283A')
        Blank()
        Text(this.selected === item.id ? '已选中' : '待指认')
          .fontSize(11)
          .fontColor(this.selected === item.id ? '#8A6A2F' : '#9A9A9A')
      }
      .width('100%')
      Text(item.desc)
        .fontSize(12)
        .fontColor('#6B6B6B')
        .width('100%')
        .margin({ top: 6 })
    }
    .padding(14)
    .width('100%')
    .backgroundColor(this.selected === item.id ? '#EFE5D2' : '#FFFFFF')
    .borderRadius(10)
    .border({ width: 1, color: this.selected === item.id ? '#C9A96A' : '#E4DCCC' })
    .margin({ bottom: 10 })
    .onClick(() => {
      this.selected = item.id;
    })
  }

  async submit(): Promise<void> {
    if (!DeductionService.canDeduce(this.clueIds, this.flags)) {
      this.tip = '尚未达到指认门槛：需要至少 4 条线索，并已解锁“人为点灯”推论';
      return;
    }
    if (this.selected.length === 0) {
      this.tip = '请先选择一名指认对象';
      return;
    }
    const endingId: string = DeductionService.judge(this.clueIds, this.selected, this.flags);
    GameStore.finish(endingId);
    const ctx = getContext(this) as common.UIAbilityContext;
    await SaveRepository.save(SaveRepository.AUTO_SLOT, GameStore.snapshot());
    await PrefsStore.setLastSlot(ctx, SaveRepository.AUTO_SLOT);
    router.replaceUrl({ url: 'pages/EndingPage' });
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
        Text('线索 ' + this.clueIds.length + ' / 6')
          .fontSize(13)
          .fontColor('#8A6A2F')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12 })

      Text('推理台')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#22283A')
        .width('94%')
        .margin({ top: 16 })
      Text('把线索拼起来，写下你要指认的人。结局由证据条件决定，而不是由选项决定。')
        .fontSize(12)
        .fontColor('#6B6B6B')
        .width('94%')
        .margin({ top: 6 })

      Row() {
        Text('条件判定：')
          .fontSize(12)
          .fontColor('#6B6B6B')
        Text('线索 ' + this.clueIds.length + '/6')
          .fontSize(12)
          .fontColor('#22283A')
        Text('状态：' + (this.flags['artificial'] === true ? '人为点灯已确认' : '推论未解锁'))
          .fontSize(12)
          .fontColor('#8A6A2F')
          .margin({ left: 8 })
      }
      .width('94%')
      .margin({ top: 12 })

      Scroll() {
        Column() {
          ForEach(StoryData.SUSPECTS, (item: Suspect) => {
            this.SuspectCard(item);
          }, (item: Suspect) => item.id)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .width('94%')
      .margin({ top: 12 })
      .scrollBar(BarState.Off)

      if (this.tip.length > 0) {
        Text(this.tip)
          .fontSize(12)
          .fontColor('#B06A4A')
          .width('94%')
          .margin({ bottom: 8 })
      }

      Button('提交最终判断')
        .width('94%')
        .height(48)
        .backgroundColor('#22283A')
        .fontColor('#FFFFFF')
        .margin({ bottom: 24 })
        .onClick(() => {
          this.submit();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F1EA')
  }
}
