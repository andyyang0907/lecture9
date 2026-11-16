import 'package:flutter/material.dart';

import '../models/book.dart';

/// 模拟断网开关：列表页与详情页的 AppBar 都能切换，便于复现白屏问题。
class AppSettings {
  AppSettings._();

  static bool simulateOffline = false;
}

/// 断网时抛出的异常，界面据此展示错误态与重试入口。
class OfflineException implements Exception {
  const OfflineException();

  @override
  String toString() => '网络不可用，请检查连接后重试';
}

/// 本地藏书仓库：数据固定，详情用延迟模拟一次网络请求。
class BookRepository {
  BookRepository._();

  static final BookRepository instance = BookRepository._();

  static const List<Book> books = [
    Book(
      id: 1,
      title: 'Flutter实战',
      author: '亢少军',
      category: '计算机',
      year: 2022,
      mark: '码',
      coverColors: [Color(0xFF3B5BDB), Color(0xFF4C6EF5)],
      intro:
          '本书由浅入深地讲解 Flutter 的核心机制与工程实践，从 Widget 树、布局约束到动画、路由与状态管理，'
          '每一章都配有可直接运行的案例。第 9 章专门讨论动画：隐式动画适合状态驱动的属性过渡，'
          '显式动画则用 AnimationController 精确编排多段与循环效果，两者的边界正是工程选型的关键。',
    ),
    Book(
      id: 2,
      title: '活着',
      author: '余华',
      category: '文学',
      year: 1993,
      mark: '文',
      coverColors: [Color(0xFFB8860B), Color(0xFFDAA520)],
      intro:
          '地主少爷福贵嗜赌成性，终于赌光了家业。此后他经历了内战、三反五反、大跃进等社会变革，'
          '亲人一个个离他而去，最后只剩一头老牛与他相伴。小说以近乎冷静的笔调写尽苦难，'
          '却在苦难尽头留下“活着”本身的重量。',
    ),
    Book(
      id: 3,
      title: '人类简史',
      author: '尤瓦尔·赫拉利',
      category: '历史',
      year: 2014,
      mark: '史',
      coverColors: [Color(0xFF0B7285), Color(0xFF15AABF)],
      intro:
          '从认知革命、农业革命到科学革命，作者用一条清晰的线索重述智人如何成为地球的主宰。'
          '书中提出“想象的共同体”概念：国家、货币、公司都建立在共同相信的故事之上。'
          '宏大叙事之外，作者也不断追问：人类真的因此更幸福了吗？',
    ),
    Book(
      id: 4,
      title: '设计中的设计',
      author: '原研哉',
      category: '设计',
      year: 2006,
      mark: '设',
      coverColors: [Color(0xFF7048E8), Color(0xFF9775FA)],
      intro:
          '原研哉以无印良品等案例，阐释“设计不是造物，而是重新发现日常”。'
          '书中强调“空”的力量：留白让使用者参与意义的生成。'
          '对界面设计同样适用——好的界面不是把功能堆满，而是让信息各得其所，'
          '让用户的注意力落在真正重要的地方。',
    ),
    Book(
      id: 5,
      title: '代码整洁之道',
      author: 'Robert C. Martin',
      category: '计算机',
      year: 2010,
      mark: '码',
      coverColors: [Color(0xFF2B8A3E), Color(0xFF40C057)],
      intro:
          '命名、函数、注释、错误处理、单元测试……本书把“代码质量”拆成一条条可执行的规则。'
          '核心观点是：代码被阅读的时间远多于被编写的时间，因此可读性优先于聪明技巧。'
          '配套的坏味道清单可以直接当作代码评审的检查表。',
    ),
    Book(
      id: 6,
      title: '百年孤独',
      author: '加西亚·马尔克斯',
      category: '文学',
      year: 1967,
      mark: '文',
      coverColors: [Color(0xFF9C36B5), Color(0xFFBE4BDB)],
      intro:
          '布恩迪亚家族七代人的命运在马孔多小镇上循环往复，姓名重复、性格重复，'
          '连孤独也代代相传。魔幻现实主义在这里不是修辞，而是拉美历史的另一种写法。'
          '那句著名的开头，把过去、现在与未来压缩进同一个句子。',
    ),
    Book(
      id: 7,
      title: '月亮与六便士',
      author: '毛姆',
      category: '文学',
      year: 1919,
      mark: '文',
      coverColors: [Color(0xFF1864AB), Color(0xFF339AF0)],
      intro:
          '证券经纪人思特里克兰德突然抛下体面的生活，去巴黎学画，最终远赴塔希提岛。'
          '满地都是六便士，他却抬头看见了月亮。小说讨论的不是艺术至上，'
          '而是一个更尖锐的问题：当理想与责任冲突时，人该如何为自己的选择负责。',
    ),
    Book(
      id: 8,
      title: '置身事内',
      author: '兰小欢',
      category: '经济',
      year: 2021,
      mark: '经',
      coverColors: [Color(0xFFC92A2A), Color(0xFFE03131)],
      intro:
          '从地方政府的视角解释中国经济的运行逻辑：土地财政如何形成、城市化如何推进、'
          '地方债从何而来、产业政策如何落地。作者把复杂的财政与金融机制拆成可理解的链条，'
          '既讲成绩也讲代价，是理解宏观经济的一本入门书。',
    ),
    Book(
      id: 9,
      title: '思考，快与慢',
      author: '丹尼尔·卡尼曼',
      category: '心理',
      year: 2011,
      mark: '心',
      coverColors: [Color(0xFF5F3DC4), Color(0xFF7950F2)],
      intro:
          '作者把大脑分成两套系统：快速、直觉、省力的系统 1，与缓慢、理性、费力的系统 2。'
          '大多数判断偏差来自系统 1 的自动反应。书中用大量实验展示锚定效应、损失厌恶、'
          '过度自信等机制，并提醒读者：认识到偏差，并不能自动消除偏差。',
    ),
    Book(
      id: 10,
      title: '万历十五年',
      author: '黄仁宇',
      category: '历史',
      year: 1981,
      mark: '史',
      coverColors: [Color(0xFFA61E4D), Color(0xFFD6336C)],
      intro:
          '作者选取万历十五年这个看似平淡的年份，从皇帝、首辅、清官、名将、思想家等人物切入，'
          '勾勒出明代官僚体系的结构性困境。书中提出“大历史观”：'
          '不少看似偶然的失败，其实是制度设计与技术条件共同作用的必然结果。',
    ),
    Book(
      id: 11,
      title: '写给大家看的设计书',
      author: 'Robin Williams',
      category: '设计',
      year: 2009,
      mark: '设',
      coverColors: [Color(0xFFE8590C), Color(0xFFFF922B)],
      intro:
          '对比、重复、对齐、亲密性——四条原则撑起全书。作者用大量前后对比图说明：'
          '设计感并非天赋，而是可训练的判断力。即使不做专业设计，'
          '把这四条原则用于排版、幻灯片和界面，效果也会立刻不同。',
    ),
    Book(
      id: 12,
      title: '深度工作',
      author: '卡尔·纽波特',
      category: '效率',
      year: 2016,
      mark: '效',
      coverColors: [Color(0xFF087F5B), Color(0xFF20C997)],
      intro:
          '在碎片化信息占据注意力的时代，深度工作——在无干扰状态下专注进行高认知强度活动——'
          '正变得稀缺而珍贵。作者给出时间块、关机仪式、注意力预算等可操作方法，'
          '核心不是更努力，而是为真正重要的工作保留完整的心智带宽。',
    ),
  ];

  Future<Book> fetchBook(int id) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (AppSettings.simulateOffline) {
      throw const OfflineException();
    }
    return books.firstWhere((book) => book.id == id);
  }

  Future<String> fetchDetail(Book book) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (AppSettings.simulateOffline) {
      throw const OfflineException();
    }
    return book.intro;
  }
}
