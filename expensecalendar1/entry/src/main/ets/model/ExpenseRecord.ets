// 消费分类枚举
export enum ExpenseCategory {
  FOOD = '餐饮',
  TRANSPORT = '交通',
  SHOPPING = '购物',
  ENTERTAINMENT = '娱乐',
  HOUSING = '住房',
  MEDICAL = '医疗',
  EDUCATION = '教育',
  OTHER = '其他'
}

// 分类对应的颜色
export const CategoryColors: Record<string, string> = {
  '餐饮': '#FF6B6B',
  '交通': '#4ECDC4',
  '购物': '#45B7D1',
  '娱乐': '#96CEB4',
  '住房': '#FFEAA7',
  '医疗': '#DDA0DD',
  '教育': '#98D8C8',
  '其他': '#C9C9C9'
}

// 分类图标
export const CategoryIcons: Record<string, string> = {
  '餐饮': '🍽',
  '交通': '🚌',
  '购物': '🛍',
  '娱乐': '🎮',
  '住房': '🏠',
  '医疗': '💊',
  '教育': '📚',
  '其他': '📌'
}

// 获取所有分类名称
export function getAllCategories(): string[] {
  return Object.values(ExpenseCategory)
}

// 消费记录数据类
export class ExpenseRecord {
  id: number = 0
  amount: number = 0
  category: string = ExpenseCategory.OTHER
  date: string = ''       // 格式: YYYY-MM-DD
  note: string = ''
  createTime: number = 0  // 时间戳

  constructor(id: number = 0, amount: number = 0, category: string = ExpenseCategory.OTHER,
              date: string = '', note: string = '', createTime: number = 0) {
    this.id = id
    this.amount = amount
    this.category = category
    this.date = date
    this.note = note
    this.createTime = createTime
  }
}
