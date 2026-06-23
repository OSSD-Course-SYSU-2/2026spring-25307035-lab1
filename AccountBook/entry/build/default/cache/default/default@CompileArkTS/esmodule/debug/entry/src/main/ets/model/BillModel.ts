// 账单类型枚举
export enum BillType {
    EXPENSE = 0,
    INCOME = 1 // 收入
}
// 账单数据模型
export interface BillInfo {
    id: number;
    type: BillType;
    category: string; // 分类名称
    categoryIcon: string; // 分类图标
    amount: number; // 金额
    note: string; // 备注
    date: string; // 日期 yyyy-MM-dd
    createTime: number; // 创建时间戳
}
// 分类模型
export interface CategoryInfo {
    name: string;
    icon: string;
    type: BillType;
}
// 默认支出分类
export const EXPENSE_CATEGORIES: CategoryInfo[] = [
    { name: '餐饮', icon: '🍜', type: BillType.EXPENSE },
    { name: '交通', icon: '🚌', type: BillType.EXPENSE },
    { name: '购物', icon: '🛒', type: BillType.EXPENSE },
    { name: '娱乐', icon: '🎮', type: BillType.EXPENSE },
    { name: '居住', icon: '🏠', type: BillType.EXPENSE },
    { name: '医疗', icon: '💊', type: BillType.EXPENSE },
    { name: '教育', icon: '📚', type: BillType.EXPENSE },
    { name: '通讯', icon: '📱', type: BillType.EXPENSE },
    { name: '服饰', icon: '👔', type: BillType.EXPENSE },
    { name: '其他', icon: '📝', type: BillType.EXPENSE },
];
// 默认收入分类
export const INCOME_CATEGORIES: CategoryInfo[] = [
    { name: '工资', icon: '💰', type: BillType.INCOME },
    { name: '奖金', icon: '🎁', type: BillType.INCOME },
    { name: '理财', icon: '📈', type: BillType.INCOME },
    { name: '兼职', icon: '💼', type: BillType.INCOME },
    { name: '红包', icon: '🧧', type: BillType.INCOME },
    { name: '其他', icon: '📝', type: BillType.INCOME },
];
