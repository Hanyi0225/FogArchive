import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { GameStore } from '../domain/GameStore';
import { StoryEngine } from '../domain/StoryEngine';
import { SaveRepository } from '../data/SaveRepository';
import { PrefsStore } from '../data/PrefsStore';
import { LoadResult, SlotInfo } from '../model/Models';

@Entry
@Component
struct ArchivePage {
  @State slots: SlotInfo[] = [];
  @State tip: string = '';

  aboutToAppear(): void {
    this.refresh();
  }

  async refresh(): Promise<void> {
    this.slots = await SaveRepository.listSlots();
  }

  @Builder
  SlotRow(slot: SlotInfo) {
    Column() {
      Row() {
        Text('档位 ' + slot.slotId)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#22283A')
        Blank()
        Text(slot.empty ? '空档' : StoryEngine.phaseLabel(slot.phase))
          .fontSize(11)
          .fontColor(slot.empty ? '#9A9A9A' : '#8A6A2F')
      }
      .width('100%')

      Text(slot.empty ? '尚未写入进度' :
        '线索 ' + slot.clueCount + ' 条 · ' + this.timeText(slot.savedAt))
        .fontSize(11)
        .fontColor('#6B6B6B')
        .width('100%')
        .margin({ top: 4 })

      Row() {
        Button('写入')
          .layoutWeight(1)
          .height(36)
          .fontSize(13)
          .backgroundColor('#22283A')
          .fontColor('#FFFFFF')
          .onClick(() => {
            this.writeSlot(slot.slotId);
          })
        Button('读取')
          .layoutWeight(1)
          .height(36)
          .fontSize(13)
          .backgroundColor('#FFFFFF')
          .fontColor('#22283A')
          .border({ width: 1, color: '#D8D2C4' })
          .margin({ left: 8 })
          .onClick(() => {
            this.readSlot(slot.slotId);
          })
        Button('清除')
          .layoutWeight(1)
          .height(36)
          .fontSize(13)
          .backgroundColor('#F2ECE0')
          .fontColor('#7A5C2A')
          .margin({ left: 8 })
          .onClick(() => {
            this.clearSlot(slot.slotId);
          })
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .padding(14)
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(10)
    .border({ width: 1, color: '#E4DCCC' })
    .margin({ bottom: 10 })
  }

  timeText(ts: number): string {
    if (ts <= 0) {
      return '无时间戳';
    }
    const d: Date = new Date(ts);
    const m: number = d.getMonth() + 1;
    const day: number = d.getDate();
    const h: string = d.getHours() < 10 ? '0' + d.getHours() : '' + d.getHours();
    const min: string = d.getMinutes() < 10 ? '0' + d.getMinutes() : '' + d.getMinutes();
    return `${m}月${day}日 ${h}:${min}`;
  }

  async writeSlot(slotId: number): Promise<void> {
    await SaveRepository.save(slotId, GameStore.snapshot());
    const ctx = getContext(this) as common.UIAbilityContext;
    await PrefsStore.setLastSlot(ctx, slotId);
    this.tip = '已写入档位 ' + slotId;
    await this.refresh();
  }

  async readSlot(slotId: number): Promise<void> {
    const result: LoadResult = await SaveRepository.load(slotId);
    if (result.damaged) {
      this.tip = '存档损坏：' + result.message + '，已按空档处理';
      return;
    }
    if (result.snapshot.visited.length === 0) {
      this.tip = '档位 ' + slotId + ' 为空';
      return;
    }
    GameStore.restore(result.snapshot);
    const ctx = getContext(this) as common.UIAbilityContext;
    await PrefsStore.setLastSlot(ctx, slotId);
    this.tip = '已从档位 ' + slotId + ' 恢复';
    router.replaceUrl({ url: 'pages/StoryPage' });
  }

  async clearSlot(slotId: number): Promise<void> {
    await SaveRepository.clear(slotId);
    this.tip = '已清除档位 ' + slotId;
    await this.refresh();
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
        Text('RDB 三档位')
          .fontSize(12)
          .fontColor('#8A6A2F')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12 })

      Text('存档管理')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#22283A')
        .width('94%')
        .margin({ top: 16 })
      Text('档位 1 为自动档，每次推进节点都会覆盖写入；档位 2、3 可手动保存不同进度。')
        .fontSize(12)
        .fontColor('#6B6B6B')
        .width('94%')
        .margin({ top: 6 })

      if (this.tip.length > 0) {
        Text(this.tip)
          .fontSize(12)
          .fontColor('#8A6A2F')
          .width('94%')
          .margin({ top: 8 })
      }

      Scroll() {
        Column() {
          ForEach(this.slots, (slot: SlotInfo) => {
            this.SlotRow(slot);
          }, (slot: SlotInfo) => '' + slot.slotId)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .width('94%')
      .margin({ top: 10, bottom: 20 })
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F1EA')
  }
}
