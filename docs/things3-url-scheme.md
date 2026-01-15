# Things URL Scheme - 完整技術文檔

> 來源：https://culturedcode.com/things/support/articles/2803573/
> 下載日期：2026-01-15

## 概述

Things URL Scheme 允許開發者和專業用戶通過特殊的 URL 連結向 Things 應用發送命令。基本格式為：

```
things:///commandName?parameter1=value1&parameter2=value2
```

**目前版本**: 2

### 資料型別

| 型別 | 說明 |
|------|------|
| `string` | 百分比編碼，最大 4,000 字符 |
| `date string` | 格式：`today`, `tomorrow`, `yyyy-mm-dd` 或自然語言 |
| `time string` | 格式：`9:30PM` 或 `21:30` |
| `date time string` | 格式：`2018-02-25@14:00` |
| `ISO8601 date time string` | 格式：`2018-03-10T14:30:00Z` |
| `boolean` | `true` 或 `false` |
| `JSON string` | 標準 JSON 格式 |

### 授權認證

修改現有數據的命令需要授權 token。取得方式：

- **Mac**: Things → Settings → General → Enable Things URLs → Manage
- **iOS**: Settings → General → Things URLs

### 取得 ID

**取得任務 ID**:
- Mac: 右鍵點擊任務 → Share → Copy Link
- iOS: 打開任務 → 工具欄 → Share → Copy Link

**取得列表 ID**:
- Mac: 右鍵點擊側邊欄列表 → Share → Copy Link
- iOS: 進入列表 → 右上角 → Share → Copy Link

---

## 命令詳解

### 1. `add` - 添加任務

**基本語法**:
```
things:///add?title=Buy%20milk
```

**參數說明**:

| 參數 | 型別 | 說明 |
|------|------|------|
| `title` | string | 任務標題（可選） |
| `titles` | string | 多行任務標題（`%0a` 分隔） |
| `notes` | string | 任務備註（最大 10,000 字符） |
| `when` | date string | 時間（today, tomorrow, evening, anytime, someday, 日期或日期時間） |
| `deadline` | date string | 截止日期 |
| `tags` | string | 逗號分隔的標籤名稱 |
| `checklist-items` | string | 清單項目（`%0a` 分隔，最多 100 項） |
| `list` | string | 項目或區域名稱 |
| `list-id` | string | 項目或區域 ID |
| `heading` | string | 項目內的標題 |
| `heading-id` | string | 標題 ID |
| `completed` | boolean | 是否完成（預設 false） |
| `canceled` | boolean | 是否取消（優先級高於 completed） |
| `show-quick-entry` | boolean | 顯示快速輸入對話框 |
| `reveal` | boolean | 導航到新任務 |
| `creation-date` | ISO8601 | 創建日期 |
| `completion-date` | ISO8601 | 完成日期 |

**範例**:

```
# 創建簡單任務
things:///add?title=Buy%20milk

# 創建帶備註的任務
things:///add?title=Buy%20milk&notes=Low%20fat

# 創建多個任務
things:///add?titles=Milk%0aBeer%0aCheese&list=Shopping

# 創建帶日期和標籤的任務
things:///add?title=Call%20doctor&when=next%20monday&tags=Health

# 創建帶提醒的任務
things:///add?title=Collect%20dry%20cleaning&when=evening@6pm
```

**返回參數** (`x-success`):
- `x-things-id`: 逗號分隔的任務 ID 列表

**限制**: 10 秒內最多添加 250 個任務

---

### 2. `add-project` - 添加項目

**基本語法**:
```
things:///add-project?title=Build%20treehouse&when=today
```

**參數說明**:

| 參數 | 型別 | 說明 |
|------|------|------|
| `title` | string | 項目標題 |
| `notes` | string | 項目備註（最大 10,000 字符） |
| `when` | date string | 開始時間 |
| `deadline` | date string | 截止日期 |
| `tags` | string | 逗號分隔標籤 |
| `area` | string | 區域名稱 |
| `area-id` | string | 區域 ID |
| `to-dos` | string | 任務標題列表（`%0a` 分隔） |
| `completed` | boolean | 是否完成 |
| `canceled` | boolean | 是否取消 |
| `reveal` | boolean | 導航到項目 |
| `creation-date` | ISO8601 | 創建日期 |
| `completion-date` | ISO8601 | 完成日期 |

**範例**:

```
# 創建項目
things:///add-project?title=Build%20treehouse&when=today

# 在指定區域創建項目
things:///add-project?title=Plan%20Birthday%20Party&area=Family

# 創建帶任務的項目
things:///add-project?title=Build%20treehouse&to-dos=Plan%0aDesign%0aBuild
```

**返回參數** (`x-success`):
- `x-things-id`: 項目 ID

---

### 3. `update` - 更新任務

**基本語法**:
```
things:///update?id=4BE64FEA-8FEF-4F4F-B8B2-4E74605D5FA5&when=today
```

**必需參數**:
- `id`: 任務 ID
- `auth-token`: 授權令牌

**其他參數**:

| 參數 | 型別 | 說明 |
|------|------|------|
| `title` | string | 新標題 |
| `notes` | string | 替換備註 |
| `prepend-notes` | string | 在備註前添加文字 |
| `append-notes` | string | 在備註後添加文字 |
| `when` | date string | 更新時間 |
| `deadline` | date string | 更新截止日期 |
| `tags` | string | 替換所有標籤 |
| `add-tags` | string | 添加標籤 |
| `checklist-items` | string | 替換清單項目 |
| `prepend-checklist-items` | string | 在清單前添加 |
| `append-checklist-items` | string | 在清單後添加 |
| `list` | string | 移動到項目/區域 |
| `list-id` | string | 移動到項目/區域 ID |
| `heading` | string | 移動到標題 |
| `heading-id` | string | 移動到標題 ID |
| `completed` | boolean | 標記完成/未完成 |
| `canceled` | boolean | 標記取消 |
| `reveal` | boolean | 導航到任務 |
| `duplicate` | boolean | 複製後更新 |
| `creation-date` | ISO8601 | 設置創建日期 |
| `completion-date` | ISO8601 | 設置完成日期 |

**範例**:

```
# 更新任務日期
things:///update?id=4BE64FEA-8FEF-4F4F-B8B2-4E74605D5FA5&auth-token=YOUR_TOKEN&when=today

# 更新標題
things:///update?id=4BE64FEA-8FEF-4F4F-B8B2-4E74605D5FA5&auth-token=YOUR_TOKEN&title=Buy%20bread

# 追加備註
things:///update?id=4BE64FEA-8FEF-4F4F-B8B2-4E74605D5FA5&auth-token=YOUR_TOKEN&append-notes=Wholemeal%20bread

# 添加清單項目
things:///update?id=4BE64FEA-8FEF-4F4F-B8B2-4E74605D5FA5&auth-token=YOUR_TOKEN&append-checklist-items=Cheese%0aBread%0aEggplant

# 清除截止日期
things:///update?id=4BE64FEA-8FEF-4F4F-B8B2-4E74605D5FA5&auth-token=YOUR_TOKEN&deadline=
```

**返回參數** (`x-success`):
- `x-things-id`: 更新的任務 ID

**注意**: 在參數後添加 `=` 但不提供值可清除該欄位

---

### 4. `update-project` - 更新項目

**基本語法**:
```
things:///update-project?id=852763FD-5954-4DF9-A88A-2ADD808BD279&auth-token=TOKEN&when=tomorrow
```

**必需參數**:
- `id`: 項目 ID
- `auth-token`: 授權令牌

**參數說明**:

| 參數 | 型別 | 說明 |
|------|------|------|
| `title` | string | 項目標題 |
| `notes` | string | 替換備註 |
| `prepend-notes` | string | 前置備註 |
| `append-notes` | string | 附加備註 |
| `when` | date string | 開始時間 |
| `deadline` | date string | 截止日期 |
| `tags` | string | 替換標籤 |
| `add-tags` | string | 添加標籤 |
| `area` | string | 區域名稱 |
| `area-id` | string | 區域 ID |
| `completed` | boolean | 標記完成 |
| `canceled` | boolean | 標記取消 |
| `reveal` | boolean | 導航到項目 |
| `duplicate` | boolean | 複製後更新 |
| `creation-date` | ISO8601 | 創建日期 |
| `completion-date` | ISO8601 | 完成日期 |

**範例**:

```
# 設置項目開始時間
things:///update-project?id=852763FD-5954-4DF9-A88A-2ADD808BD279&auth-token=TOKEN&when=tomorrow

# 添加標籤
things:///update-project?id=852763FD-5954-4DF9-A88A-2ADD808BD279&auth-token=TOKEN&add-tags=Important

# 前置備註
things:///update-project?id=852763FD-5954-4DF9-A88A-2ADD808BD279&auth-token=TOKEN&prepend-notes=SFO%20to%20JFK

# 清除截止日期
things:///update-project?id=852763FD-5954-4DF9-A88A-2ADD808BD279&auth-token=TOKEN&deadline=
```

**返回參數** (`x-success`):
- `x-things-id`: 更新的項目 ID

---

### 5. `show` - 導航顯示

**基本語法**:
```
things:///show?id=today
```

**參數說明**:

| 參數 | 說明 |
|------|------|
| `id` | 區域/項目/標籤/任務 ID 或內置列表 ID |
| `query` | 區域/項目/標籤名稱或內置列表名稱 |
| `filter` | 逗號分隔的標籤名稱（過濾用） |

**內置列表 ID**:
- `inbox` - 收件箱
- `today` - 今天
- `anytime` - 隨時
- `upcoming` - 即將開始
- `someday` - 某天
- `logbook` - 日誌
- `tomorrow` - 明天
- `deadlines` - 截止日期
- `repeating` - 重複任務
- `all-projects` - 所有項目
- `logged-projects` - 已記錄項目

**範例**:

```
# 顯示今天列表
things:///show?id=today

# 顯示特定任務
things:///show?id=8796CC16E-92FA-4809-9A26-36194985E87B

# 顯示項目
things:///show?id=9096CC16E-92FA-4809-9A26-36194985E44A

# 按名稱顯示項目
things:///show?query=vacation

# 按名稱顯示並過濾標籤
things:///show?query=vacation&filter=errand
```

---

### 6. `search` - 搜尋

**基本語法**:
```
things:///search?query=vacation
```

**參數說明**:

| 參數 | 說明 |
|------|------|
| `query` | 搜尋查詢（可選） |

**範例**:

```
# 搜尋特定文字
things:///search?query=vacation

# 打開搜尋屏幕
things:///search
```

---

### 7. `version` - 版本資訊

**基本語法**:
```
things:///version
```

**返回參數** (`x-success`):
- `x-things-scheme-version`: URL Scheme 版本
- `x-things-client-version`: 應用構建號

---

### 8. `json` - 進階 JSON 命令

**用途**: 開發者使用的進階命令，支持創建具有複雜結構的項目。

**基本語法**:
```
things:///json?data=[JSON_DATA]&auth-token=TOKEN
```

**參數說明**:

| 參數 | 型別 | 說明 |
|------|------|------|
| `data` | JSON string | JSON 數據（必需） |
| `auth-token` | string | 授權令牌（update 操作必需） |
| `reveal` | boolean | 導航到新建項目 |

#### JSON 對象結構

**基本字段**:
```json
{
  "type": "to-do" | "project" | "heading" | "checklist-item",
  "operation": "create" | "update",
  "id": "string (update only)",
  "attributes": { ... }
}
```

#### To-Do 對象

```json
{
  "type": "to-do",
  "attributes": {
    "title": "Milk",
    "notes": "string",
    "when": "date string",
    "deadline": "date string",
    "tags": ["tag1", "tag2"],
    "checklist-items": [ ... ],
    "list-id": "string",
    "list": "string",
    "heading-id": "string",
    "heading": "string",
    "completed": false,
    "canceled": false,
    "creation-date": "ISO8601",
    "completion-date": "ISO8601"
  }
}
```

**Update 特定屬性**:
- `prepend-notes` - 前置備註
- `append-notes` - 附加備註
- `add-tags` - 添加標籤
- `prepend-checklist-items` - 前置清單項目
- `append-checklist-items` - 附加清單項目

#### Project 對象

```json
{
  "type": "project",
  "attributes": {
    "title": "Go Shopping",
    "notes": "string",
    "when": "date string",
    "deadline": "date string",
    "tags": ["tag1", "tag2"],
    "area-id": "string",
    "area": "string",
    "completed": false,
    "canceled": false,
    "items": [ ... ],
    "creation-date": "ISO8601",
    "completion-date": "ISO8601"
  }
}
```

#### Heading 對象

```json
{
  "type": "heading",
  "attributes": {
    "title": "Sights",
    "archived": false
  }
}
```

#### Checklist Item 對象

```json
{
  "type": "checklist-item",
  "attributes": {
    "title": "Hotels",
    "completed": true,
    "canceled": false
  }
}
```

#### 完整範例

```json
[
  {
    "type": "project",
    "attributes": {
      "title": "Go Shopping",
      "items": [
        {
          "type": "to-do",
          "attributes": {
            "title": "Bread"
          }
        },
        {
          "type": "to-do",
          "attributes": {
            "title": "Milk"
          }
        }
      ]
    }
  },
  {
    "type": "project",
    "attributes": {
      "title": "Vacation in Rome",
      "notes": "Some time in August",
      "area": "Family",
      "items": [
        {
          "type": "to-do",
          "attributes": {
            "title": "Ask Sarah for travel guide"
          }
        },
        {
          "type": "heading",
          "attributes": {
            "title": "Sights"
          }
        },
        {
          "type": "to-do",
          "attributes": {
            "title": "Vatican City"
          }
        },
        {
          "type": "to-do",
          "attributes": {
            "title": "The Colosseum",
            "notes": "12€"
          }
        }
      ]
    }
  }
]
```

#### URL 編碼範例

**原始 JSON**:
```json
[{"type":"to-do","attributes":{"title":"Buy milk"}}]
```

**URL 編碼後**:
```
things:///json?data=%5B%7B%22type%22:%22to-do%22,%22attributes%22:%7B%22title%22:%22Buy%20milk%22%7D%7D%5D
```

**返回參數** (`x-success`):
- `x-things-ids`: JSON 數組，包含創建的 ID 列表

---

## x-callback-url 支援

所有命令都支持 x-callback-url 約定：

```
things:///add?title=Buy%20milk&x-success=myapp://&x-error=myapp://error&x-cancel=myapp://cancel
```

**回調參數**:
- `x-success`: 成功時調用
- `x-error`: 出錯時調用
- `x-cancel`: 取消時調用

---

## 啟用 URL Scheme

首次使用時，Things 會提示是否啟用此功能。

**設定位置**:
- **Mac**: Things → Settings → General
- **iOS**: Settings → General → Things URLs

---

## 廢棄命令

### `add-json` (已廢棄)

使用 `json` 命令替代。

---

## 開發資源

Cultured Code 提供 Swift 輔助類用於生成 JSON 資料：

**GitHub 倉庫**: [ThingsJSONCoder](https://github.com/culturedcode/ThingsJSONCoder)

---

## 常見使用場景

### 場景 1: 創建簡單任務

```
things:///add?title=Buy%20groceries&when=today&tags=Shopping
```

### 場景 2: 複製並更新任務

```
things:///update?id=TASK_ID&auth-token=TOKEN&duplicate=true&when=tomorrow
```

### 場景 3: 批量創建項目和任務

```
things:///json?data=%5B%7B%22type%22:%22project%22,%22attributes%22:%7B%22title%22:%22Vacation%22,%22items%22:%5B%7B%22type%22:%22to-do%22,%22attributes%22:%7B%22title%22:%22Book%20hotel%22%7D%7D%5D%7D%7D%5D&auth-token=TOKEN
```

---

**文檔版本**: URL Scheme v2
