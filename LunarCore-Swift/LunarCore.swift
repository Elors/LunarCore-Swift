//
//  LunarCore.swift
//  LunarCore-Swift
//
//  Created by Elors on 2016/11/6.
//  Copyright © 2016年 elors. All rights reserved.
//

import Foundation

private let minYear     = 1890     // 最小年限
private let maxYear     = 2100     // 最大年限
private let weekStart   = 0        // 周首日（可改成 app 配置）

/**
 *  获得本地化的字符串 这里 app 可以自行实现
 *
 *  @param text key
 *
 *  @return 本地化字符串
 */
private func i18n(_ key: String?) -> String {
    return key ?? "nil"
}

/**
 *  获得不为空的字符串
 *
 *  @param text text
 *
 *  @return text
 */
private func $(_ text: String?) -> String {
    return (text != nil ? text! : "")
}


/**
 *  缓存 主要是缓存节气信息
 */
public class LCMemoryCache: NSObject {
    
    var current: Int? {
        didSet {
            clear()
        }
    }
    var cache: [String: Any?]
    
    override init() {
        cache = [String: Any?]()
        super.init()
    }
    public func get(key: String) -> Any? {
        let a = cache[key] ?? nil
        return a
    }
    public func setKey(_ key: String, Value value: Any?) {
        cache[key] = value
    }
    private func clear() {
        cache.removeAll()
    }
}


// MARK: - LunarCore
class LunarCore {
    
    /**
     * 1890 - 2100 年的农历数据
     * 数据格式：[0,2,9,21936]
     * [闰月所在月，0为没有闰月; *正月初一对应公历月; *正月初一对应公历日; *农历每月的天数的数组（需转换为二进制,得到每月大小，0=小月(29日),1=大月(30日)）;]
     */
    private let lunarInfo = [[2,1,21,22184],[0,2,9,21936],[6,1,30,9656],[0,2,17,9584],[0,2,6,21168],[5,1,26,43344],[0,2,13,59728],[0,2,2,27296],[3,1,22,44368],[0,2,10,43856],[8,1,30,19304],[0,2,19,19168],[0,2,8,42352],[5,1,29,21096],[0,2,16,53856],[0,2,4,55632],[4,1,25,27304],[0,2,13,22176],[0,2,2,39632],[2,1,22,19176],[0,2,10,19168],[6,1,30,42200],[0,2,18,42192],[0,2,6,53840],[5,1,26,54568],[0,2,14,46400],[0,2,3,54944],[2,1,23,38608],[0,2,11,38320],[7,2,1,18872],[0,2,20,18800],[0,2,8,42160],[5,1,28,45656],[0,2,16,27216],[0,2,5,27968],[4,1,24,44456],[0,2,13,11104],[0,2,2,38256],[2,1,23,18808],[0,2,10,18800],[6,1,30,25776],[0,2,17,54432],[0,2,6,59984],[5,1,26,27976],[0,2,14,23248],[0,2,4,11104],[3,1,24,37744],[0,2,11,37600],[7,1,31,51560],[0,2,19,51536],[0,2,8,54432],[6,1,27,55888],[0,2,15,46416],[0,2,5,22176],[4,1,25,43736],[0,2,13,9680],[0,2,2,37584],[2,1,22,51544],[0,2,10,43344],[7,1,29,46248],[0,2,17,27808],[0,2,6,46416],[5,1,27,21928],[0,2,14,19872],[0,2,3,42416],[3,1,24,21176],[0,2,12,21168],[8,1,31,43344],[0,2,18,59728],[0,2,8,27296],[6,1,28,44368],[0,2,15,43856],[0,2,5,19296],[4,1,25,42352],[0,2,13,42352],[0,2,2,21088],[3,1,21,59696],[0,2,9,55632],[7,1,30,23208],[0,2,17,22176],[0,2,6,38608],[5,1,27,19176],[0,2,15,19152],[0,2,3,42192],[4,1,23,53864],[0,2,11,53840],[8,1,31,54568],[0,2,18,46400],[0,2,7,46752],[6,1,28,38608],[0,2,16,38320],[0,2,5,18864],[4,1,25,42168],[0,2,13,42160],[10,2,2,45656],[0,2,20,27216],[0,2,9,27968],[6,1,29,44448],[0,2,17,43872],[0,2,6,38256],[5,1,27,18808],[0,2,15,18800],[0,2,4,25776],[3,1,23,27216],[0,2,10,59984],[8,1,31,27432],[0,2,19,23232],[0,2,7,43872],[5,1,28,37736],[0,2,16,37600],[0,2,5,51552],[4,1,24,54440],[0,2,12,54432],[0,2,1,55888],[2,1,22,23208],[0,2,9,22176],[7,1,29,43736],[0,2,18,9680],[0,2,7,37584],[5,1,26,51544],[0,2,14,43344],[0,2,3,46240],[4,1,23,46416],[0,2,10,44368],[9,1,31,21928],[0,2,19,19360],[0,2,8,42416],[6,1,28,21176],[0,2,16,21168],[0,2,5,43312],[4,1,25,29864],[0,2,12,27296],[0,2,1,44368],[2,1,22,19880],[0,2,10,19296],[6,1,29,42352],[0,2,17,42208],[0,2,6,53856],[5,1,26,59696],[0,2,13,54576],[0,2,3,23200],[3,1,23,27472],[0,2,11,38608],[11,1,31,19176],[0,2,19,19152],[0,2,8,42192],[6,1,28,53848],[0,2,15,53840],[0,2,4,54560],[5,1,24,55968],[0,2,12,46496],[0,2,1,22224],[2,1,22,19160],[0,2,10,18864],[7,1,30,42168],[0,2,17,42160],[0,2,6,43600],[5,1,26,46376],[0,2,14,27936],[0,2,2,44448],[3,1,23,21936],[0,2,11,37744],[8,2,1,18808],[0,2,19,18800],[0,2,8,25776],[6,1,28,27216],[0,2,15,59984],[0,2,4,27424],[4,1,24,43872],[0,2,12,43744],[0,2,2,37600],[3,1,21,51568],[0,2,9,51552],[7,1,29,54440],[0,2,17,54432],[0,2,5,55888],[5,1,26,23208],[0,2,14,22176],[0,2,3,42704],[4,1,23,21224],[0,2,11,21200],[8,1,31,43352],[0,2,19,43344],[0,2,7,46240],[6,1,27,46416],[0,2,15,44368],[0,2,5,21920],[4,1,24,42448],[0,2,12,42416],[0,2,2,21168],[3,1,22,43320],[0,2,9,26928],[7,1,29,29336],[0,2,17,27296],[0,2,6,44368],[5,1,26,19880],[0,2,14,19296],[0,2,3,42352],[4,1,24,21104],[0,2,10,53856],[8,1,30,59696],[0,2,18,54560],[0,2,7,55968],[6,1,27,27472],[0,2,15,22224],[0,2,5,19168],[4,1,25,42216],[0,2,12,42192],[0,2,1,53584],[2,1,21,55592],[0,2,9,54560]]
    
    /**
     * 二十四节气数据，节气点时间（单位是分钟）
     * 从0小寒起算
     */
    private let termInfo = [0,21208,42467,63836,85337,107014,128867,150921,173149,195551,218072,240693,263343,285989,308563,331033,353350,375494,397447,419210,440795,462224,483532,504758]
    
    private let solarDaysOfMonth = [31, 0, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    
    // Memory Cache
    private lazy var memoryCache: LCMemoryCache = {
        return LCMemoryCache()
    }()
    // GMT 0 的时区
    private lazy var timeZone: TimeZone = {
        return TimeZone(secondsFromGMT: 0)!
    }()
    // 错误码表
    private lazy var errorCode: [Int: String] = {
        return [
            100: "输入的年份超过了可查询范围，仅支持1891至2100年",
            101: "参数输入错误，请查阅文档"
        ]
    }()
    // 1890 ~ 2100 年农历新年数据
    private lazy var springFestival: [[Int]] = {
        return [[1,21],[2,9],[1,30],[2,17],[2,6],[1,26],[2,14],[2,2],[1,22],[2,10],[1,31],[2,19],[2,8],[1,29],[2,16],[2,4],[1,25],[2,13],[2,2],[1,22],[2,10],[1,30],[2,18],[2,6],[1,26],[2,14],[2,4],[1,23],[2,11],[2,1],[2,20],[2,8],[1,28],[2,16],[2,5],[1,24],[2,13],[2,2],[1,23],[2,10],[1,30],[2,17],[2,6],[1,26],[2,14],[2,4],[1,24],[2,11],[1,31],[2,19],[2,8],[1,27],[2,15],[2,5],[1,25],[2,13],[2,2],[1,22],[2,10],[1,29],[2,17],[2,6],[1,27],[2,14],[2,3],[1,24],[2,12],[1,31],[2,18],[2,8],[1,28],[2,15],[2,5],[1,25],[2,13],[2,2],[1,21],[2,9],[1,30],[2,17],[2,6],[1,27],[2,15],[2,3],[1,23],[2,11],[1,31],[2,18],[2,7],[1,28],[2,16],[2,5],[1,25],[2,13],[2,2],[2,20],[2,9],[1,29],[2,17],[2,6],[1,27],[2,15],[2,4],[1,23],[2,10],[1,31],[2,19],[2,7],[1,28],[2,16],[2,5],[1,24],[2,12],[2,1],[1,22],[2,9],[1,29],[2,18],[2,7],[1,26],[2,14],[2,3],[1,23],[2,10],[1,31],[2,19],[2,8],[1,28],[2,16],[2,5],[1,25],[2,12],[2,1],[1,22],[2,10],[1,29],[2,17],[2,6],[1,26],[2,13],[2,3],[1,23],[2,11],[1,31],[2,19],[2,8],[1,28],[2,15],[2,4],[1,24],[2,12],[2,1],[1,22],[2,10],[1,30],[2,17],[2,6],[1,26],[2,14],[2,2],[1,23],[2,11],[2,1],[2,19],[2,8],[1,28],[2,15],[2,4],[1,24],[2,12],[2,2],[1,21],[2,9],[1,29],[2,17],[2,5],[1,26],[2,14],[2,3],[1,23],[2,11],[1,31],[2,19],[2,7],[1,27],[2,15],[2,5],[1,24],[2,12],[2,2],[1,22],[2,9],[1,29],[2,17],[2,6],[1,26],[2,14],[2,3],[1,24],[2,10],[1,30],[2,18],[2,7],[1,27],[2,15],[2,5],[1,25],[2,12],[2,1],[1,21],[2,9]]
    }()
    // 农历数据
    private lazy var lunarCalendarData: [String: [String]] = {
        var dict = ["heavenlyStems": ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]] // 天干
        dict["earthlyBranches"] = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"] // 地支
        dict["zodiac"] = ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"] // 对应地支十二生肖
        dict["solarTerm"] = ["小寒", "大寒", "立春", "雨水", "惊蛰", "春分", "清明", "谷雨", "立夏", "小满", "芒种", "夏至", "小暑", "大暑", "立秋", "处暑", "白露", "秋分", "寒露", "霜降", "立冬", "小雪", "大雪", "冬至"] // 二十四节气
        dict["monthCn"] = ["正", "二", "三", "四", "五", "六", "七", "八", "九", "十", "冬", "腊"]
        dict["dateCn"] = ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十", "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十", "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十", "卅一"]
        return dict
    }()
    // 中国节日放假安排，外部设置，0无特殊安排，1工作，2放假
    private lazy var worktime: [String: [String: Int]] = {
        var dicts = [String: Dictionary<String, Int>]()
        dicts["y2013"] = ["d0101":2,"d0102":2,"d0103":2,"d0105":1,"d0106":1,"d0209":2,"d0210":2,"d0211":2,"d0212":2,"d0213":2,"d0214":2,"d0215":2,"d0216":1,"d0217":1,"d0404":2,"d0405":2,"d0406":2,"d0407":1,"d0427":1,"d0428":1,"d0429":2,"d0430":2,"d0501":2,"d0608":1,"d0609":1,"d0610":2,"d0611":2,"d0612":2,"d0919":2,"d0920":2,"d0921":2,"d0922":1,"d0929":1,"d1001":2,"d1002":2,"d1003":2,"d1004":2,"d1005":2,"d1006":2,"d1007":2,"d1012":1]
        
        dicts["y2014"] = ["d0101":2,"d0126":1,"d0131":2,"d0201":2,"d0202":2,"d0203":2,"d0204":2,"d0205":2,"d0206":2,"d0208":1,"d0405":2,"d0407":2,"d0501":2,"d0502":2,"d0503":2,"d0504":1,"d0602":2,"d0908":2,"d0928":1,"d1001":2,"d1002":2,"d1003":2,"d1004":2,"d1005":2,"d1006":2,"d1007":2,"d1011":1]
        
        dicts["y2015"] = ["d0101":2,"d0102":2,"d0103":2,"d0104":1,"d0215":1,"d0218":2,"d0219":2,"d0220":2,"d0221":2,"d0222":2,"d0223":2,"d0224":2,"d0228":1,"d0404":2,"d0405":2,"d0406":2,"d0501":2,"d0502":2,"d0503":2,"d0620":2,"d0621":2,"d0622":2,"d0903":2,"d0904":2,"d0905":2,"d0906":1,"d0926":2,"d0927":2,"d1001":2,"d1002":2,"d1003":2,"d1004":2,"d1005":2,"d1006":2,"d1007":2,"d1010":1]
        
        dicts["y2016"] = ["d0101":2,"d0102":2,"d0103":2,"d0206":1,"d0207":2,"d0208":2,"d0209":2,"d0210":2,"d0211":2,"d0212":2,"d0213":2,"d0214":1,"d0402":2,"d0403":2,"d0404":2,"d0430":2,"d0501":2,"d0502":2,"d0609":2,"d0610":2,"d0611":2,"d0612":1,"d0915":2,"d0916":2,"d0917":2,"d0918":1,"d1001":2,"d1002":2,"d1003":2,"d1004":2,"d1005":2,"d1006":2,"d1007":2,"d1008":1,"d1009":1]
        return dicts
    }()
    // 公历节日
    // 星号表示不重要的节日
    // 破折号前面的是缩略写法
    private lazy var solarFestival: [String: String] = {
        return [
            "d0101":"元旦节",
            "d0120":"水瓶",
            "d0202":"湿地日-世界湿地日",
            "d0210":"*国际气象节",
            "d0214":"情人节",
            "d0219":"双鱼",
            "d0301":"*国际海豹日",
            "d0303":"*全国爱耳日",
            "d0305":"学雷锋-学雷锋纪念日",
            "d0308":"妇女节",
            "d0312":"植树节 孙中山逝世纪念日",
            "d0314":"*国际警察日",
            "d0315":"消费者-消费者权益日",
            "d0317":"*中国国医节 国际航海日",
            "d0321":"白羊 世界森林日 消除种族歧视国际日 世界儿歌日",
            "d0322":"*世界水日",
            "d0323":"*世界气象日",
            "d0324":"*世界防治结核病日",
            "d0325":"*全国中小学生安全教育日",
            "d0330":"*巴勒斯坦国土日",
            "d0401":"愚人节 全国爱国卫生运动月 税收宣传月",
            "d0407":"*世界卫生日",
            "d0420":"金牛",
            "d0422":"地球日-世界地球日",
            "d0423":"*世界图书和版权日",
            "d0424":"*亚非新闻工作者日",
            "d0501":"劳动节",
            "d0504":"青年节",
            "d0505":"*碘缺乏病防治日",
            "d0508":"*世界红十字日",
            "d0512":"护士节-国际护士节",
            "d0515":"*国际家庭日",
            "d0517":"*世界电信日",
            "d0518":"博物馆-国际博物馆日",
            "d0520":"*全国学生营养日",
            "d0521":"双子",
            "d0522":"*国际生物多样性日",
            "d0531":"*世界无烟日",
            "d0601":"儿童节-国际儿童节",
            "d0605":"环境日-世界环境日",
            "d0606":"*全国爱眼日",
            "d0617":"*防治荒漠化和干旱日",
            "d0622":"巨蟹",
            "d0623":"奥林匹克-国际奥林匹克日",
            "d0625":"*全国土地日",
            "d0626":"*国际禁毒日",
            "d0701":"建党节 香港回归纪念日 中共诞辰 世界建筑日",
            "d0702":"*国际体育记者日",
            "d0707":"*抗日战争纪念日",
            "d0711":"*世界人口日",
            "d0723":"狮子",
            "d0730":"*非洲妇女日",
            "d0801":"建军节",
            "d0808":"*中国男子节(爸爸节)",
            "d0823":"处女",
            "d0903":"抗日战争-抗日战争胜利纪念",
            "d0908":"*国际扫盲日 国际新闻工作者日",
            "d0909":"*毛泽东逝世纪念",
            "d0910":"教师节-中国教师节",
            "d0914":"*世界清洁地球日",
            "d0916":"*国际臭氧层保护日",
            "d0918":"*九一八事变纪念日",
            "d0920":"*国际爱牙日",
            "d0923":"天秤",
            "d0927":"*世界旅游日",
            "d0928":"*孔子诞辰",
            "d1001":"国庆节 世界音乐日 国际老人节",
            "d1002":"*国际和平与民主自由斗争日",
            "d1004":"*世界动物日",
            "d1006":"*老人节",
            "d1008":"*全国高血压日",
            "d1009":"*世界邮政日 万国邮联日",
            "d1010":"*辛亥革命纪念日 世界精神卫生日",
            "d1013":"*世界保健日 国际教师节",
            "d1014":"*世界标准日",
            "d1015":"*国际盲人节(白手杖节)",
            "d1016":"*世界粮食日",
            "d1017":"*世界消除贫困日",
            "d1022":"*世界传统医药日",
            "d1024":"天蝎 联合国日 世界发展信息日",
            "d1031":"万圣节 世界勤俭日",
            "d1107":"*十月社会主义革命纪念日",
            "d1108":"*中国记者日",
            "d1109":"*全国消防安全宣传教育日",
            "d1110":"*世界青年节",
            "d1111":"光棍节 国际科学与和平周(本日所属的一周)",
            "d1112":"*孙中山诞辰纪念日",
            "d1114":"*世界糖尿病日",
            "d1117":"*国际大学生节 世界学生节",
            "d1121":"*世界问候日 世界电视日",
            "d1123":"射手",
            "d1129":"*国际声援巴勒斯坦人民国际日",
            "d1201":"艾滋病-世界艾滋病日",
            "d1203":"*世界残疾人日",
            "d1205":"*国际经济和社会发展志愿人员日",
            "d1208":"*国际儿童电视日",
            "d1209":"*世界足球日",
            "d1210":"*世界人权日",
            "d1212":"*西安事变纪念日",
            "d1213":"*南京大屠杀(1937年)纪念日！紧记血泪史！",
            "d1220":"*澳门回归纪念",
            "d1221":"*国际篮球日",
            "d1222":"摩羯",
            "d1224":"平安夜",
            "d1225":"圣诞节",
            "d1226":"*毛泽东诞辰纪念"
        ]
    }()
    // 农历节日
    private lazy var lunarFestival: [String: String] = {
        return [
            "d0101":"春节",
            "d0115":"元宵节",
            "d0202":"龙抬头节",
            "d0505":"端午节",
            "d0707":"七夕节",
            "d0715":"中元节",
            "d0815":"中秋节",
            "d0909":"重阳节",
            "d1001":"寒衣节",
            "d1015":"下元节",
            "d1208":"腊八节",
            "d1223":"小年",
            "d0100":"除夕"
        ]
    }()
    // 周节日
    private lazy var weekFestival: [String: String] = {
        return [
            "0513":"*世界哮喘日",
            "0521":"母亲节-国际母亲节 救助贫困母亲日",
            "0531":"*全国助残日",
            "0533":"*国际牛奶日",
            "0627":"*中国文化遗产日",
            "0631":"父亲节",
            "0717":"*国际合作节",
            "0731":"*被奴役国家周",
            "0933":"*国际和平日",
            "0937":"*全民国防教育日",
            "0941":"*国际聋人节 世界儿童日",
            "0951":"*世界海事日 世界心脏病日",
            "1012":"*国际住房日 世界建筑日 世界人居日",
            "1024":"*国际减灾日",
            "1025":"*世界视觉日",
            "1145":"感恩节",
            "1221":"*国际儿童电视广播日"
        ]
    }()
    
    /**
     *  格式化日期
     *
     *  @param month 月份
     *  @param day   日期
     *
     *  @return 格式化后的日期
     */
    private func formatDay(_ month: Int, _ day: Int) -> String {
        return String(format: "d%02d%02d", (month+1), day)
    }
    
    /**
     *  以年月和长度构造一个日历
     *
     *  @param year  年
     *  @param month 月
     *  @param len   参数
     *  @param start 开始日期
     *
     *  @return 整月日历
     */
    private func createMonthData(_ year: Int, _ month: Int, _ len: Int, _ start: Int) -> [Dictionary<String, Int>] {
        
        var monthData: [Dictionary<String, Int>] = []
        
        if len < 1 {
            return monthData
        }
        
        var k = start
        for _ in 0...len {
            let dict = [
                "year": year,
                "month": month,
                "day": k
            ]
            k += 1
            monthData.append(dict)
        }
        return monthData
    }
    
    /**
     *  构造 NSDate
     *
     *  @param year  年
     *  @param month 月
     *  @param day   日
     *
     *  @return NSDate
     */
    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date? {
        let calendar = Calendar.current
        var comp = DateComponents()
        comp.year = year
        comp.month = month+1
        comp.day = day
        let date = calendar.date(from: comp)
        return date
    }
    
    /**
     *  构造 NSDate
     *
     *  @param year  年
     *  @param month 月
     *  @param day   日
     *
     *  @return NSDate
     */
    private func newDate(_ year: Int, _  month: Int, _  day: Int) -> Date {
        return date(year, month-1, day)!
    }

    /**
     *  获得以周为单位的节日
     *
     *  @param year  年
     *  @param month 月
     *  @param day   日
     *
     *  @return 节日
     */
    private func getWeekFestival(_ year: Int, _ month: Int, _ day: Int) -> String? {
        
        let date = newDate(year, month, day)
        let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        let comps = gregorian.dateComponents([Calendar.Component.weekday], from: date)
        let weekDay = comps.weekday!
        
        // 这个时候要数出cWeekDay是第几个
        var weekDayCount = 0
        for _ in 1...day {
            let curDate = newDate(year, month, day)
            let weekComp = gregorian.dateComponents([Calendar.Component.weekday], from: curDate)
            if weekComp.weekday == weekDay {
                weekDayCount += 1
            }
        }
        
        let key = String(format: "%02d%d%d", month, weekDayCount, weekDay)
        let festival = weekFestival[key]
        if festival != nil {
            return i18n(festival)
        }
        return nil
    }
    
    /**
     *  判断农历年闰月数
     *
     *  @param year 农历年
     *
     *  @return 闰月数 （月份从1开始）
     */
    private func getLunarLeapYear(_ year: Int) -> Int {
        let yearData = lunarInfo[year - minYear]
        return yearData[0]
    }
    
    private func toString(_ num: Int?) -> [AnyObject?] {
        var arr = [AnyObject?]()
        var tempNum = num
        while tempNum != 0 {
            arr.append(String(tempNum! & 1) as AnyObject?)
            tempNum = tempNum! >> 1
        }
        return arr.reversed()
    }
    
    /**
     *  获取农历年份一年的每月的天数及一年的总天数
     *
     *  @param year 农历年
     *
     *  @return 总天数
     */
    private func getLunarYearDays(_ year: Int) -> [String: AnyObject?] {
        let yearData = lunarInfo[year - minYear]
        let leapMonth = yearData[safe: 0] // 闰月
        let monthData = yearData[safe: 3]
        var monthDataArr = toString(monthData)
        
        // 还原数据至16位,少于16位的在前面插入0（二进制存储时前面的0被忽略）
        for _ in 0...(16-monthDataArr.count) {
             monthDataArr.insert(0 as AnyObject?, at: 0)
        }
        
        let len = (leapMonth != nil) ? 13 : 12 // 该年有几个月
        var yearDays = 0
        var monthDays: [Int] = []
        
        for i in 0...len {
            if let num = monthDataArr[safe: i], (num as? NSNumber)?.intValue == 0 {
                yearDays += 29
                monthDays.append(29)
            }else {
                yearDays += 30
                monthDays.append(30)
            }
        }
        
        return [
            "yearDays": yearDays as AnyObject?,
            "monthDays": monthDays as AnyObject?
        ]
    }
    
    /**
     *  通过间隔天数查找农历日期
     *
     *  @param year    农历年
     *  @param between 间隔天数
     *
     *  @return 农历日期
     */
    private func getLunarDateByBetween(_ year: Int, _ between: Int) -> [Int] {
        let lunarYearDays = getLunarYearDays(year)
        let end = between > 0 ? between : ((lunarYearDays["yearDays"] as? NSNumber)?.intValue)! - abs(between)
        let monthDays = lunarYearDays["monthDays"] as! [Int]
        var tempDays = 0
        var month = 0
        for i in 0...monthDays.count {
            let monthDaysI = monthDays[safe: i]
            tempDays += monthDaysI!
            if tempDays > end {
                month = i
                tempDays = tempDays - monthDaysI!
                break
            }
        }
        
        return [year, month, (end - tempDays + 1)]
    }
    
    /**
     *  两个公历日期之间的天数
     *
     *  @param year   年
     *  @param month  月
     *  @param day    日
     *  @param year1  年2
     *  @param month1 月2
     *  @param day1   日2
     *
     *  @return 间隔天数
     */
    private func getDaysBetweenSolar(_ year: Int, _ month: Int, _ day: Int, _ year1: Int, _ month1: Int, _ day1: Int) -> Int {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = timeZone
        var comp = DateComponents()
        comp.year = year; comp.month = month + 1; comp.day = day
        let date = calendar.date(from: comp)!
        comp.year = year1; comp.month = month1 + 1; comp.day = day1
        let date1 = calendar.date(from: comp)!
        return Int((date1.timeIntervalSince1970 - date.timeIntervalSince1970) / 86400)
    }
    
    /**
     *  根据距离正月初一的天数计算农历日期
     *
     *  @param year  公历年
     *  @param month 月
     *  @param day   日
     *
     *  @return 农历日期
     */
    private func getLunarByBetween(_ year: Int, _ month: Int, _ day: Int) -> [Int] {
        let yearData = lunarInfo[safe: (year - minYear)]
        let zenMonth = yearData?[safe: 1]
        let zenDay = yearData?[safe: 2]
        let between = getDaysBetweenSolar(year, zenMonth! - 1, zenDay!, year, month, day)
        if between == 0 { //正月初一
            return [year, 0, 1]
        }else {
            let lunarYear = between > 0 ? year : year - 1
            return getLunarDateByBetween(lunarYear, between)
        }
    }
    
    /**
     *  某年的第n个节气为几日
     *  由于农历24节气交节时刻采用近似算法，可能存在少量误差(30分钟内)
     *  31556925974.7为地球公转周期，是毫秒
     *  1890年的正小寒点：01-05 16:02:31，1890年为基准点
     *
     *  @param y    公历年
     *  @param n    第几个节气，从0小寒起算
     */
    private func UTC(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ min: Int, _ sec: Int) -> TimeInterval {
        var calendar = Calendar.current
        var comp = DateComponents()
        comp.year = year; comp.month = month + 1; comp.day = day
        comp.hour = hour; comp.minute = min; comp.second = sec
        calendar.timeZone = timeZone
        let date = calendar.date(from: comp)
        return (date?.timeIntervalSince1970 ?? 0) * 1000
    }
    
    /**
     *  根据 NSDate 获得天
     *
     *  @param date date
     *
     *  @return 天
     */
    private func getDay(_ date: Date) -> Int {
        let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        let components = gregorian.dateComponents([Calendar.Component.weekday], from: date)
        return (components.weekday! - 1)
    }
    
    private func getTerm(_ y: Int, _ n: Int) -> Int {
        var sec = UTC(1890, 0, 5, 16, 2, 31)
        sec += (31556925974.7 * Double(y - 1890)) + (Double(termInfo[safe: n] ?? 0) * 60000.0)
        let date = Date(timeIntervalSince1970: (sec / 1000))
        var gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        gregorian.timeZone = timeZone
        let components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        return components.day!
    }
    
    /**
     *  获取公历年一年的二十四节气
     *
     *  @param year 年
     *
     *  @return 日期: 节气名
     */
    private func getYearTerm(_ year: Int) -> [String: AnyObject?] {
        var res = [String: AnyObject?]()
        var month = 0
        let solarTerm = lunarCalendarData["solarTerm"]
        
        for i in 0...24 {
            let day = getTerm(year, i)
            if (i & 1) == 00 {
                month += 1
            }
            let key = formatDay(month - 1, day)
            let value = i18n((solarTerm?[safe: i] ?? ""))
            res[key] = value as AnyObject?
        }
        return res
    }
    
    /**
     *  获得生肖
     *
     *  @param year 年
     *
     *  @return 生肖
     */
    private func getYearZodiac(_ year: Int) -> String? {
        let num = year - 1890 + 25  // 参考干支纪年的计算，生肖对应地支
        return i18n((lunarCalendarData["zodiac"]?[num % 12]))
    }
    
    /**
     *  计算天干地支
     *
     *  @param num 60进制中的位置(把60个天干地支，当成一个60进制的数)
     *
     *  @return 天干地支
     */
    private func cyclical(_ num: Double) -> String {
        let tiangan = i18n(lunarCalendarData["heavenlyStems"]![Int(num.truncatingRemainder(dividingBy: 10))])
        let dizhi = i18n(lunarCalendarData["earthlyBranches"]![Int(num.truncatingRemainder(dividingBy: 12))])
        return String(format: "%@%@", tiangan, dizhi)
    }
    
    /**
     *  获取干支纪年
     *
     *  @param year   干支所在年
     *  @param offset 偏移量，默认为0，便于查询一个年跨两个干支纪年（以立春为分界线）
     *
     *  @return 干支纪年
     */
    private func getLunarYearName(_ year: Int, _ offset: Int) -> String {
        // 1890年1月小寒（小寒一般是1月5或6日）以前为己丑年，在60进制中排25
        let temp = year + offset - 1915/*1890 + 25*/
        return cyclical(Double(temp))
    }
    
    /**
     *  判断公历年是否是闰年
     *
     *  @param year 公历年
     *
     *  @return 是否是闰年
     */
    private func isLeapYear(_ year: Int) -> Bool {
        return ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0))
    }
    
    /**
     *  获取公历月份的天数
     *
     *  @param year  公历年
     *  @param month 公历月
     *
     *  @return 该月天数
     */
    private func getSolarMonthDays(_ year: Int, _ month: Int) -> Int {
        if month == 1 {  // 二月 闰月处理
            return isLeapYear(year) ? 29 : 28
        }else { // 普通月份查表
            return solarDaysOfMonth[month]
        }
    }
    
    /**
     *  统一日期输入参数（输入月份从1开始，内部月份统一从0开始）
     *
     *  @param year  年
     *  @param month 月
     *  @param day   日
     *
     *  @return 格式化后的日期
     */
    private func formatDate(_ year: Int, _ month: Int, _ day: Int) -> [String : Any] {
        let now = Date()
        var gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        gregorian.timeZone = timeZone
        let components = gregorian.dateComponents([.year, .month, .day], from: now)
        let year = year
        let month = month - 1
        let day = day > 0 ? day : components.day!
        
        if year < minYear || year > maxYear {
            return [
                "error": 100 as Any,
                "msg": errorCode[100] as Any
            ]
        }
        
        return [
            "year": year as Any,
            "month": month as Any,
            "day": day as Any
        ]
    }
    
    /**
     *  判断是否处于农历新年
     *
     *  @param _year  阳历年
     *  @param _month 阳历月
     *  @param _day   阳历日
     *
     *  @return YES 表示处于农历新年
     */
    private func isNewLunarYear(_ year: Int, _ month: Int, _ day: Int) -> Bool {
        let springFestivalDate = springFestival[year - minYear]
        let springFestivalMonth = springFestivalDate[0]
        let springFestivalDay = springFestivalDate[1]
        
        if month > springFestivalMonth {
            return true
        }else if month == springFestivalMonth {
            return (day >= springFestivalDay)
        }else {
            return false
        }
    }
    
    /**
     *  公历转换成农历
     *
     *  @param _year  公历年
     *  @param _month 公历月
     *  @param _day   公历日
     *
     *  @return 农历年月日
     */
    func solarToLunar(_ year: Int, _ month: Int, _ day: Int) -> [AnyHashable: Any] {
        
        var inputDate = formatDate(year, month, day)
        
        if (inputDate["error"] != nil) {
            return inputDate
        }
        
        let year = inputDate["year"]! as! Int
        let month = inputDate["month"]! as! Int
        let day = inputDate["day"]! as! Int
        memoryCache.current = year
        
        // 二十四节气
        var termList = [AnyHashable: Any]()
        let termListCache = memoryCache.get(key: "termList")
        if termListCache != nil {
            termList = termListCache as! [AnyHashable : Any]
        }else {
            termList = getYearTerm(year)
            memoryCache.setKey("termList", Value: termList)
        }
        
        // 干支所在年份
        let GanZhiYear = isNewLunarYear(year, month, day) ? year + 1 : year
        
        let lunarDate = getLunarByBetween(year, month, day)
        let lunarDate0 = Int(lunarDate[0])
        let lunarDate1 = Int(lunarDate[1])
        let lunarDate2 = Int(lunarDate[2])
        
        let lunarLeapMonth = getLunarLeapYear(lunarDate0)
        let lunarMonthName: String?
        
        if lunarLeapMonth > 0 && lunarLeapMonth == lunarDate1 {
            let mStr = i18n((lunarCalendarData["monthCn"]?[lunarDate1 - 1]));
            lunarMonthName = String(format: "闰%@月", mStr)
        } else if(lunarLeapMonth > 0 && lunarDate1 > lunarLeapMonth) {
            let mStr = i18n((lunarCalendarData["monthCn"]?[lunarDate1 - 1]));
            lunarMonthName = String(format:"%@月", mStr)
        } else {
            let mStr = i18n((lunarCalendarData["monthCn"]?[lunarDate1]));
            lunarMonthName = String(format:"%@月", mStr)
        }
        
        // 农历节日判断
        let lunarFtv: String?
        let lunarMonthDays = getLunarYearDays(lunarDate0)["monthDays"]! as! [Int]
        
        // 除夕
        if (lunarDate1 == lunarMonthDays.count - 1) &&
            (lunarDate2 == (lunarMonthDays[lunarMonthDays.count - 1] as Int)) {
            lunarFtv = lunarFestival["d0100"];
        } else if (lunarLeapMonth > 0 && lunarDate1 > lunarLeapMonth) {
            let date = formatDay(lunarDate1 - 1, lunarDate2)
            lunarFtv = lunarFestival[date];
        } else {
            let date = formatDay(lunarDate1, lunarDate2)
            lunarFtv = lunarFestival[date]
        }
        
        // 放假安排：0无特殊安排，1工作，2放假
        let yearKey = String(format: "y%d", year)
        let dayKey = formatDay(month, day)
        var workTime = 0
        let hasData = worktime[yearKey]?[dayKey]
        if hasData != nil {
            workTime = hasData!
        }
        
        let res = [
            "lunarDay": lunarDate[2],
            "lunarMonthName": lunarMonthName,
            "lunarDayName": lunarCalendarData["dateCn"]?[lunarDate2 - 1],
            "solarFestival": i18n(solarFestival[formatDay(month, day)]),
            "lunarFestival": i18n(lunarFtv),
            "weekFestival": getWeekFestival(year, month + 1, day),
            "worktime": workTime,
            "GanZhiYear": getLunarYearName(GanZhiYear, 0),
            "zodiac": getYearZodiac(GanZhiYear),
            "term": termList[formatDay(month, day)]
        ];
        return res
    }
    
    /**
     *  某月公历
     *
     *  @param _year  公历年
     *  @param _month 公历月
     *
     *  @return 公历
     */
    private func solarCalendar(_ year: Int, _ month: Int) -> [String: Any] {
        
        let inputDate = formatDate(year, month, -1)
        
        if inputDate["eror"] != nil {
            return inputDate
        }
        
        let year = inputDate["year"]! as! Int
        let month = inputDate["month"]! as! Int
        
        let firstDate = date(year, month, 1)
        
        var res: [String: AnyObject] = [
            "firstDay": getDay(firstDate!) as AnyObject, // 该月1号星期几
            "monthDays": getSolarMonthDays(year, month) as AnyObject, // 该月天数
            "monthData": [] as AnyObject
        ]
        
        res["monthData"] = createMonthData(year, month + 1, 0, 1) as AnyObject?
        
        var firstDay = res["firstDay"] as! Int
        
        let identifier = NSLocale.current.identifier.lowercased()
        if identifier.hasSuffix("japanese") || identifier.hasSuffix("buddhist") {
            // 处理日本日历和佛教日历
            firstDay += 1
        }
        
        let moveDays = (firstDay >= weekStart) ? firstDay : (firstDay + 7)
        let preFillDays = moveDays - weekStart
        
        // 前补齐
        let preYear = (month - 1 < 0) ? (year - 1) : (year)
        let preMonth = (month - 1 < 0) ? (11) : (month - 1)
        let preMonthDays = getSolarMonthDays(preYear, preMonth)
        let preMonthData = createMonthData(preYear, preMonth + 1, preFillDays, preMonthDays - preFillDays + 1)
        var tempResMonthData: NSArray = res["monthData"] as! [Any] as NSArray
        res["monthData"] = (preMonthData as NSArray).addingObjects(from: tempResMonthData as! [Any]) as AnyObject?
        // 后补齐
        let length = (res["monthData"] as! [[String: Int]]).count
        let fillLen = 7 * 6 - length // [matrix 7 * 6]
        if fillLen != 0 {
            let nextYear = (month + 1 > 11) ? (year + 1) : (year)
            let nextMonth = (month + 1 > 11) ? (0) : (month + 1)
            let nextMonthData = createMonthData(nextYear, nextMonth + 1, fillLen, 1)
            tempResMonthData = (res["monthData"] as! [[String: Int]]) as NSArray
            res["monthData"] = tempResMonthData.addingObjects(from: nextMonthData) as AnyObject?
        }
        return res
    }
    
    
    func calendar(_ year: Int, _ month: Int) -> [String: Any] {
        
        var inputDate = formatDate(year, month, -1)
        
        if (inputDate["error"] != nil) {
            return inputDate
        }
        
        let year = inputDate["year"]! as! Int
        let month = inputDate["month"]! as! Int
        
        var calendarData = solarCalendar(year, month + 1)
        var monthData = calendarData["monthData"] as! [[String: Int]]
        
        for i in 0..<monthData.count {
            var cData = monthData[i]
            let lunarData = solarToLunar(Int(cData["year"]!), Int(cData["month"]!), Int(cData["day"]!))
            var array = calendarData["monthData"] as! [[String: Any!]]
            for (key, value) in lunarData {
                array[i][(key as! String)] = value
            }
            calendarData["monthData"] = array
        }
        return calendarData
    }
    
}
