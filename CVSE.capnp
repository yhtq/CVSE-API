@0xbc35d800bb63a3ae;

interface Cvse {

    # UTC 时间戳
    # seconds 为秒数，nanoseconds 为纳秒数
    struct Time {
        seconds @0 :Int64;
        nanoseconds @1 :Int32;
    }

    struct Rank {
        enum RankValue {
            domestic @0;   # 国产榜
            sv @1;  # SV 榜
            utau @2;    # UTAU 榜
        }
        value @0 :RankValue;
    }

    # 对数据库中已有数据的视频，修改其收录信息
    # 这些信息中，avid bvid 是必须的，其他信息若为空
    # 由于 Server 实现问题，目前要求所有 field 都提供，可将 has 设为 false
    # 则不做改动
    struct ModifyEntry {
        avid @0 :Text;  # 视频 AV 号
        bvid @1 :Text;  # 视频 BV 号
        hasIsExamined @2 :Bool;  # 是否修改审核信息
        isExamined @3 :Bool;  # 是否已审核
        hasRanks @4 :Bool;  # 是否修改榜单收录信息
        ranks @5 :List(Rank);  # 应收录的榜单，空列表表示都不收录
        hasIsRepublish @6 :Bool;  # 是否修改转载信息
        isRepublish @7 :Bool;  # 是否为转载
        hasStaffInfo @8 :Bool;  # 是否修改 staff 信息
        staffInfo @9 :Text;  # staff 信息
    }

    updateModifyEntry @0 (entries :List(ModifyEntry));

    # 录入新曲
    # 所有信息均必须
    struct RecordingNewEntry {
        avid @0 :Text;  # 视频 AV 号
        bvid @1 :Text;  # 视频 BV 号
        title @2 :Text;  # 视频标题
        uploader @3 :Text;  # 投稿人
        upFace @4 :Text;  # 投稿人头像 URL
        copyright @5 :Int32;  # 版权类型，0 自制，1 转载，可能为 2
        pubdate @6 :Time;  # 发布时间
        duration @7 :Int32;  # 视频时长，单位秒
        page @8 :Int32;  # 分 P 个数
        cover @9 :Text;  # 视频封面 URL
        desc @10 :Text;  # 视频简介
        tags @11 :List(Text);  # 视频标签列表
        isExamined @12 :Bool;  # 是否已经收录
        ranks @13 :List(Rank);  # 应收录的榜单，空列表表示都不收录
        isRepublish @14 :Bool;  # 是否为转载
        staffInfo @15 :Text;  # staff 信息
    }

    # 录入新视频
    # 若 replace 为 true，则会替换已有的同 BV 号的视频信息
    # 否则，遇到相同 BV 号的视频会报错（但其余信息仍会被录入）
    updateNewEntry @1 (entries :List(RecordingNewEntry), replace: Bool);

    # 录入数据
    # 所有信息均必须
    # 新曲也需要使用该接口录入数据
    struct RecordingDataEntry {
        avid @0 :Text;  # 视频 AV 号
        bvid @1 :Text;  # 视频 BV 号
        view @2 :Int64;  # 播放数
        favorite @3 :Int64;  # 收藏数
        coin @4 :Int64;  # 硬币数
        like @5 :Int64;  # 点赞数
        danmaku @6 :Int64;  # 弹幕数
        reply @7 :Int64;  # 评论数
        share @8 :Int64;  # 分享数
        date @9 :Time; # 采集时间的时间戳
    }

    # 录入旧曲信息
    updateRecordingDataEntry @2 (entries :List(RecordingDataEntry) );

    struct Index {
        avid @0 :Text;  # 视频 AV 号
        bvid @1 :Text;  # 视频 BV 号
    }
    # 获取所有数据库中信息
    # 参数 get_unexamined 指示是否获取未经收录的项
    # 参数 get_unincluded 指示是否获取未被收录的项
    # 参数 from_date 和 to_date 指定 pubdate 的时间范围 [from_date, to_date)
    getAll @3 (
        get_unexamined :Bool,
        get_unincluded :Bool,
        from_date: Time,
        to_date: Time
    ) -> (indices :List(Index));

    # 获取指定视频的信息
    # 若其中某些项未找到，则会报错
    lookupMetaInfo @4 (indices :List(Index)) -> (entries :List(RecordingNewEntry));

    # 获取指定视频在指定时间段 [from_date, to_date) 的数据
    lookupDataInfo @5 (indices :List(Index), from_date: Time, to_date: Time) -> (entries :List(List(RecordingDataEntry)));

    # 获取指定视频在指定时间段 [from_date, to_date) 的某个数据
    # 若其中某些项未找到，则会报错
    lookupOneDataInfo @6 (indices :List(Index), from_date: Time, to_date: Time) -> (entries :List(RecordingDataEntry));

    # 重新对某期排行榜计算排名信息
    # 自动排除 is_examined 为 True 以及 in 该 rank 为 False 的视频
    # 如果 contain_unexamined 为 True，则也包含 is_examined 为 False 并被判定为该 rank 的视频
    # 否则，只包含 is_examined 为 True 的视频
    # 注意 include_unexamined 参数不同的计算结果不会互相覆盖
    # 如果 lock 为 True，则在计算完成后锁定该期排行榜
    # 锁定后无法再次计算，再次调用该函数会报错
    # 全部重新计算开销比较大（需要运行大约一分钟），不要过于频繁的调用
    reCalculateRankings @7 (rank :Rank, index :Int32, contain_unexamined :Bool, lock :Bool);

    struct RankingInfoEntry {
        avid @0 :Text;  # 视频 AV 号
        bvid @1 :Text;  # 视频 BV 号
        prev @2 :RecordingDataEntry;  # 上期数据，对于新曲而言只是占位符，无实际含义（包括 avid bvid 也是占位符）
        curr @3 :RecordingDataEntry;  # 本期数据
        isNew @4 :Bool;  # 是否为新曲
        view @5 :Int64;  # 播放数变化
        like @6 :Int64;  # 点赞数变化
        share @7 :Int64;  # 分享数变化
        favorite @8 :Int64;  # 收藏数变化
        coin @9 :Int64;  # 硬币数变化
        reply @10 :Int64;  # 评论数变化
        danmaku @11 :Int64;  # 弹幕数变化
        pointA @12 :Float64;  # 得点A
        pointB @13 :Float64;  # 得点B
        pointC @14 :Float64;  # 得点C
        fixA @15 :Float64;  # 修正A
        fixB @16 :Float64;  # 修正B
        fixC @17 :Float64;  # 修正C
        scoreA @18 :Float64;  # 分数A
        scoreB @19 :Float64;  # 分数B
        scoreC @20 :Float64;  # 分数C
        totalScore @21 :Float64;  # 总分
        rank @22 :Int32;  # 排名
    }

    struct RankingMetaInfoStat {
        count @1 :UInt32;  # 总数
        totalView @2 :Int64;  # 总播放数
        totalLike @3 :Int64;  # 总点赞数
        totalCoin @4 :Int64;  # 总硬币数
        totalFavorite @5 :Int64;  # 总收藏数
        totalShare @6 :Int64;  # 总分享数
        totalReply @7 :Int64;  # 总评论数
        totalDanmaku @8 :Int64;  # 总弹幕数
        totalNew @9 :Int64;  # 总新增
        startTime @10 :Time;  # 开始时间
        endTime @11 :Time;  # 结束时间
    }

    # 得到参数完全相同的，上一个接口计算的信息中，排名 [from_rank, to_rank) 的索引
    # 若尚未计算，则会返回空列表
    getAllRankingInfo @8 (
        rank :Rank, index :Int32, contain_unexamined :Bool,
        from_rank :Int32, to_rank :Int32
    ) -> (entries :List(Index) );

    # 得到参数完全相同的，上一个接口计算的信息中，排名 [from_rank, to_rank) 的详细信息
    # 注意，不保证每个 index 都找到结果。如果未找到，则跳过对应项
    # 如果未计算，则返回空列表
    lookupRankingInfo @9 (
        rank :Rank, index :Int32, contain_unexamined :Bool,
        indices :List(Index)
    ) -> (entries :List(RankingInfoEntry) );

    lookupRankingMetaInfo @12 (
        rank :Rank, index :Int32, contain_unexamined :Bool
    ) -> (stat :RankingMetaInfoStat);

}
