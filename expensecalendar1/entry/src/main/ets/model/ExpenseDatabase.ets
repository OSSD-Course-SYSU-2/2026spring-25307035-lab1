import relationalStore from '@ohos.data.relationalStore';
import { ExpenseRecord, ExpenseCategory } from './ExpenseRecord';

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'ExpenseCalendar.db',
  securityLevel: relationalStore.SecurityLevel.S1
};

const SQL_CREATE_TABLE = `
  CREATE TABLE IF NOT EXISTS expense_record (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    amount REAL NOT NULL,
    category TEXT NOT NULL,
    date TEXT NOT NULL,
    note TEXT,
    createTime INTEGER NOT NULL
  )
`;

// 数据库管理单例
export class ExpenseDatabase {
  private static instance: ExpenseDatabase | null = null;
  private store: relationalStore.RdbStore | null = null;
  private context: Context | null = null;

  private constructor() {}

  static getInstance(): ExpenseDatabase {
    if (!ExpenseDatabase.instance) {
      ExpenseDatabase.instance = new ExpenseDatabase();
    }
    return ExpenseDatabase.instance;
  }

  // 初始化数据库
  async init(context: Context): Promise<void> {
    this.context = context;
    try {
      this.store = await relationalStore.getRdbStore(context, STORE_CONFIG);
      await this.store.executeSql(SQL_CREATE_TABLE);
    } catch (err) {
      console.error('数据库初始化失败: ' + JSON.stringify(err));
    }
  }

  // 添加消费记录
  async insert(record: ExpenseRecord): Promise<number> {
    if (!this.store) return -1;
    const valueBucket: relationalStore.ValuesBucket = {
      amount: record.amount,
      category: record.category,
      date: record.date,
      note: record.note,
      createTime: record.createTime
    };
    try {
      return await this.store.insert('expense_record', valueBucket);
    } catch (err) {
      console.error('插入记录失败: ' + JSON.stringify(err));
      return -1;
    }
  }

  // 更新消费记录
  async update(record: ExpenseRecord): Promise<number> {
    if (!this.store) return -1;
    const valueBucket: relationalStore.ValuesBucket = {
      amount: record.amount,
      category: record.category,
      date: record.date,
      note: record.note,
      createTime: record.createTime
    };
    const predicates = new relationalStore.RdbPredicates('expense_record');
    predicates.equalTo('id', record.id);
    try {
      return await this.store.update(valueBucket, predicates);
    } catch (err) {
      console.error('更新记录失败: ' + JSON.stringify(err));
      return -1;
    }
  }

  // 删除消费记录
  async delete(id: number): Promise<number> {
    if (!this.store) return -1;
    const predicates = new relationalStore.RdbPredicates('expense_record');
    predicates.equalTo('id', id);
    try {
      return await this.store.delete(predicates);
    } catch (err) {
      console.error('删除记录失败: ' + JSON.stringify(err));
      return -1;
    }
  }

  // 查询所有记录（按时间倒序）
  async queryAll(): Promise<ExpenseRecord[]> {
    if (!this.store) return [];
    const predicates = new relationalStore.RdbPredicates('expense_record');
    predicates.orderByDesc('createTime');
    try {
      const resultSet = await this.store.query(predicates);
      return this.parseResultSet(resultSet);
    } catch (err) {
      console.error('查询记录失败: ' + JSON.stringify(err));
      return [];
    }
  }

  // 按月份查询记录
  async queryByMonth(yearMonth: string): Promise<ExpenseRecord[]> {
    if (!this.store) return [];
    const predicates = new relationalStore.RdbPredicates('expense_record');
    predicates.like('date', yearMonth + '%');
    predicates.orderByDesc('createTime');
    try {
      const resultSet = await this.store.query(predicates);
      return this.parseResultSet(resultSet);
    } catch (err) {
      console.error('按月查询失败: ' + JSON.stringify(err));
      return [];
    }
  }

  // 按分类查询记录
  async queryByCategory(category: string): Promise<ExpenseRecord[]> {
    if (!this.store) return [];
    const predicates = new relationalStore.RdbPredicates('expense_record');
    predicates.equalTo('category', category);
    predicates.orderByDesc('createTime');
    try {
      const resultSet = await this.store.query(predicates);
      return this.parseResultSet(resultSet);
    } catch (err) {
      console.error('按分类查询失败: ' + JSON.stringify(err));
      return [];
    }
  }

  // 按月份和分类查询
  async queryByMonthAndCategory(yearMonth: string, category: string): Promise<ExpenseRecord[]> {
    if (!this.store) return [];
    const predicates = new relationalStore.RdbPredicates('expense_record');
    predicates.like('date', yearMonth + '%');
    predicates.equalTo('category', category);
    predicates.orderByDesc('createTime');
    try {
      const resultSet = await this.store.query(predicates);
      return this.parseResultSet(resultSet);
    } catch (err) {
      console.error('查询失败: ' + JSON.stringify(err));
      return [];
    }
  }

  // 解析查询结果集
  private parseResultSet(resultSet: relationalStore.ResultSet): ExpenseRecord[] {
    const records: ExpenseRecord[] = [];
    try {
      if (resultSet.rowCount === 0) {
        resultSet.close();
        return records;
      }
      resultSet.goToFirstRow();
      do {
        const record = new ExpenseRecord();
        record.id = resultSet.getLong(resultSet.getColumnIndex('id'));
        record.amount = resultSet.getDouble(resultSet.getColumnIndex('amount'));
        record.category = resultSet.getString(resultSet.getColumnIndex('category'));
        record.date = resultSet.getString(resultSet.getColumnIndex('date'));
        record.note = resultSet.getString(resultSet.getColumnIndex('note'));
        record.createTime = resultSet.getLong(resultSet.getColumnIndex('createTime'));
        records.push(record);
      } while (resultSet.goToNextRow());
      resultSet.close();
    } catch (err) {
      console.error('解析结果集失败: ' + JSON.stringify(err));
    }
    return records;
  }
}
