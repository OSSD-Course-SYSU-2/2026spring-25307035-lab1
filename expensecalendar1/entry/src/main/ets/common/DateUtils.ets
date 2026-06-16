// 日期工具类
export class DateUtils {
  // 获取当前日期字符串 YYYY-MM-DD
  static getToday(): string {
    const now = new Date()
    return DateUtils.formatDate(now)
  }

  // 格式化日期为 YYYY-MM-DD
  static formatDate(date: Date): string {
    const year = date.getFullYear()
    const month = (date.getMonth() + 1).toString().padStart(2, '0')
    const day = date.getDate().toString().padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  // 获取年月字符串 YYYY-MM
  static getYearMonth(dateStr: string): string {
    return dateStr.substring(0, 7)
  }

  // 获取当前年月
  static getCurrentYearMonth(): string {
    return DateUtils.getYearMonth(DateUtils.getToday())
  }

  // 获取月份的显示文本
  static getMonthDisplay(yearMonth: string): string {
    const parts = yearMonth.split('-')
    if (parts.length >= 2) {
      return `${parts[0]}年${parseInt(parts[1])}月`
    }
    return yearMonth
  }

  // 获取上一个月
  static getPrevMonth(yearMonth: string): string {
    const parts = yearMonth.split('-')
    let year = parseInt(parts[0])
    let month = parseInt(parts[1]) - 1
    if (month < 1) {
      month = 12
      year--
    }
    return `${year}-${month.toString().padStart(2, '0')}`
  }

  // 获取下一个月
  static getNextMonth(yearMonth: string): string {
    const parts = yearMonth.split('-')
    let year = parseInt(parts[0])
    let month = parseInt(parts[1]) + 1
    if (month > 12) {
      month = 1
      year++
    }
    return `${year}-${month.toString().padStart(2, '0')}`
  }

  // 获取时间戳
  static getTimestamp(): number {
    return Date.now()
  }
}
