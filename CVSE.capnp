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

}
