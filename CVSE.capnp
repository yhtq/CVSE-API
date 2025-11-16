@0xbc35d800bb63a3ae;

interface Cvse {

    struct Rank {
        enum RankValue {
            domestic @0;   # 国产榜
            sv @1;  # SV 榜
            utau @2;    # UTAU 榜
        }
        value @0 :RankValue;
    }

    # 对数据库中已有数据的视频，修改其收录信息
    # 这些信息中，avid bvid 是必须的，其他信息若为空（Capnp 默认允许任何一个 field 为空）
    # 则不做改动
    struct DataEntry {
        avid @0 :Text;  # 视频 AV 号
        bvid @1 :Text;  # 视频 BV 号
        ranks @2 :List(Rank);  # 应收录的榜单，空列表表示都不收录
        isRepublish @3 :Bool;  # 是否为转载
        staffInfo @4 :Text;  # staff 信息
    }

    updateDataEntry @0 (entries :List(DataEntry));
}

