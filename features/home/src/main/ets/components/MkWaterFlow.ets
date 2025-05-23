import { BreakPointType, currentBreakPoint, getGuessLikeApi, MkGoods, MkGoodsItem, MkGuess } from 'basic'
import { getRecommendAPI } from '../api'
import { GoodsItemsDataSource } from '../viewmodel/lazyForeach'
import { promptAction } from '@kit.ArkUI'
import { MkLoadingText } from '.'

@ComponentV2
export struct MkWaterFlow {
  @Require
  @Param breakPoint: string = ''
  @Require
  @Param @Once lazyRecommendGoods: GoodsItemsDataSource<MkGoodsItem> = new GoodsItemsDataSource()
  @Require @Param @Once page: number = 1
  @Local isFooterLoading: boolean = false

  async getMoreData() {
    this.page++
    //conditions For Loading More Data
    if (this.lazyRecommendGoods.totalCount() < 30) {
      //show loading
      this.isFooterLoading = true
      const res = await getRecommendAPI(this.page * 8)
      this.lazyRecommendGoods.pushDataArray(res.data.result)
      //hide loading
      this.isFooterLoading = false
    } else {
      promptAction.showToast({ message: '没有数据了~' })
      this.isFooterLoading = false
    }
  }

  build() {
    Column({ space: 5 }) {
      WaterFlow() {
        LazyForEach(this.lazyRecommendGoods, (item: MkGoodsItem, index) => {
          FlowItem() {
            MkGoods({ goods: item, index })
          }
        })
      }
      .columnsTemplate(
        new BreakPointType({
          sm: '1fr 1fr',
          md: '1fr 1fr 1fr',
          lg: '1fr 1fr 1fr 1fr'
        }).getValue(this.breakPoint)
      )
      .columnsGap(8)
      .rowsGap(10)
      .height('100%')
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
      .onReachEnd(() => {
        this.getMoreData()
      })

      //load footer
      if (this.isFooterLoading) {
        MkLoadingText()
      }
    }
  }
}

@ComponentV2
export struct MkGuessComp {
  @Local likeGoods: GoodsItemsDataSource<MkGoodsItem> = new GoodsItemsDataSource()
  @Param page:number = 1
  async aboutToAppear(){
    const res = await getGuessLikeApi()
    this.likeGoods.reloadData(res.data.result.items)
  }
  build() {
    Column(){
      MkGuess()
      MkWaterFlow({
        lazyRecommendGoods: this.likeGoods,
        breakPoint: currentBreakPoint.init().curBp,
        page: this.page
      })
    }
  }
}