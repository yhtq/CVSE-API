@0xbc35d800bb63a3ae;

interface Cvse {

    struct DayDate {
        year @0 :Int16;
        month @1 :Int8;
        day @2 :Int8;
    }

    enum RankValue {
        domestic @0;   # 国产榜
        sv @1;  # SV 榜
        utau @2;    # UTAU 榜
    }

    # 对数据库中已有数据的视频，修改其收录信息
    # 这些信息中，avid bvid 是必须的，其他信息若为空（Capnp 默认允许任何一个 field 为空）
    # 则不做改动
    struct ModifyEntry {
        avid @0 :Text;  # 视频 AV 号
        bvid @1 :Text;  # 视频 BV 号
        ranks @2 :List(RankValue);  # 应收录的榜单，空列表表示都不收录
        isRepublish @3 :Bool;  # 是否为转载
        staffInfo @4 :Text;  # staff 信息
    }

    updateModifyEntry @0 (entries :List(ModifyEntry));

    # 录入新曲
    # 所有信息均必须
    struct AddressingNewEntry {
        avid @0 :Text;  # 视频 AV 号
        bvid @1 :Text;  # 视频 BV 号
        title @2 :Text;  # 视频标题
        uploader @3 :Text;  # 投稿人
        upFace @4 :Text;  # 投稿人头像 URL
        copyright @5 :Int32;  # 版权类型，0 自制，1 转载，可能为 2
        pubdate @6 :Text;  # 发布时间，格式 YYYY-MM-DD HH:MM:SS
        duration @7 :Int32;  # 视频时长，单位秒
        page @8 :Int32;  # 分 P 个数
        cover @9 :Text;  # 视频封面 URL
        desc @10 :Text;  # 视频简介
        tags @11 :List(Text);  # 视频标签列表
    }

    # 录入新视频
    updateNewEntry @1 (entries :List(AddressingNewEntry));

    # 录入数据
    # 所有信息均必须
    # 新曲也需要使用该接口录入
    struct AddressingDataEntry {
        avid @0 :Text;  # 视频 AV 号
        bvid @1 :Text;  # 视频 BV 号
        view @2 :Int64;  # 播放数
        favorite @3 :Int64;  # 收藏数
        coin @4 :Int64;  # 硬币数
        like @5 :Int64;  # 点赞数
        danmaku @6 :Int64;  # 弹幕数
        reply @7 :Int64;  # 评论数
        share @8 :Int64;  # 分享数
        date @9 :DayDate;  # 数据对应的日期
    }

    # 录入旧曲信息
    updateAddressingDataEntry @2 (entries :List(AddressingDataEntry) );

    interface Iterator(T) {
        getHandle @0 () -> (handle :Int64);
        # 当遍历完成后，handle 会自动销毁
        next @1 (handle :Int64, count :Int32) -> (items :List(T), hasMore :Bool);
    }

    # 查询数据库中已有的视频
    struct VideoQuery {
        avid @0 :Text;
        bvid @1 :Text;
    }
    getVideoIterator @3 () -> (it :Iterator(VideoQuery) );

    # 根据日期和一列视频，获取这些视频在该日期对应的数据
    # 如果没有找到数据，则所有 field 均空
    getVideoData @4 (videos :List(VideoQuery), date :DayDate) -> (data :List(AddressingDataEntry));

}

