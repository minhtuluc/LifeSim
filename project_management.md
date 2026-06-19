# 🎯 LifeSim: Project Management — Hệ thống Quản lý Dự án

> **Vai trò:** Conversation này là **Project Lead AI (PL)**. Tất cả agent con đều báo cáo kết quả qua bạn (user) về đây. PL chịu trách nhiệm:
> 1. Phân tách task thành ticket rõ ràng, self-contained
> 2. Tạo prompt/instruction cho agent con
> 3. Review code sau khi agent con hoàn thành
> 4. Hướng dẫn merge branch vào main
> 5. Theo dõi tiến độ và chất lượng tổng thể

---

## 1. MÔ HÌNH VẬN HÀNH

```
┌──────────────────────────────────────────────────┐
│              PROJECT LEAD (PL)                    │
│         (Conversation này — persistent)           │
│                                                    │
│  Nhiệm vụ:                                       │
│  • Tạo ticket (Task Prompt)                      │
│  • Review code sau khi agent con hoàn thành      │
│  • Hướng dẫn merge + giải quyết conflict         │
│  • Cập nhật task tracker                          │
└───────────┬──────────────────────────────────────┘
            │  User copy/paste Task Prompt
            ▼
┌───────────────────────┐  ┌───────────────────────┐
│  Agent Con A           │  │  Agent Con B           │
│  (Conversation riêng)  │  │  (Conversation riêng)  │
│  Branch: feature/xxx   │  │  Branch: feature/yyy   │
│                        │  │                        │
│  Đọc: rulebook.md     │  │  Đọc: rulebook.md     │
│  Làm: code module     │  │  Làm: code module     │
│  Ghi: changelog.md    │  │  Ghi: changelog.md    │
└───────────┬───────────┘  └───────────┬───────────┘
            │  User báo "Agent A xong"   │
            ▼                            ▼
┌──────────────────────────────────────────────────┐
│              PROJECT LEAD (PL)                    │
│  • Scan codebase trên branch                     │
│  • Chạy Self-Check Checklist (Phần 14 rulebook)  │
│  • Phát hiện vi phạm Golden Rules                │
│  • Approve hoặc yêu cầu sửa                     │
│  • Hướng dẫn user merge vào main                 │
└──────────────────────────────────────────────────┘
```

---

## 2. GIT BRANCHING STRATEGY

### Quy tắc đặt tên branch
```
main                          ← production, stable
├── feature/phase1-eventbus   ← agent con tạo
├── feature/phase1-time       ← agent con tạo
├── feature/phase1-player     ← agent con tạo
└── ...
```

### Naming convention:
- `feature/phase{N}-{module_name}` — cho module mới
- `fix/phase{N}-{module_name}` — cho bug fix
- `refactor/phase{N}-{module_name}` — cho refactor

### Merge flow:
1. Agent con tạo branch, code, commit, push
2. User báo PL: "Agent con A xong branch `feature/phase1-eventbus`"
3. PL review code trên branch
4. PL approve → hướng dẫn user chạy merge commands
5. PL verify merge result

### Quy tắc quan trọng:
- **Mỗi ticket = 1 branch = 1 module** (không gộp nhiều module vào 1 branch)
- Agent con **PHẢI** merge main vào branch trước khi bắt đầu (nếu main đã có code mới)
- Nếu 2 agent cùng sửa `event_bus.gd` → merge conflict → PL giải quyết

---

## 3. TICKET SYSTEM — Cách tạo Task Prompt cho Agent Con

Mỗi ticket là một **self-contained prompt** mà user copy/paste vào conversation mới của agent con. Format:

```markdown
# 🎫 TICKET: [TICKET-ID] — [Tên module]

## Ngữ cảnh
[Mô tả ngắn gọn dự án và module này nằm ở đâu trong kiến trúc]

## Tài liệu bắt buộc phải đọc
- `agent_rulebook.md` — Đọc TOÀN BỘ trước khi code
- `implementation_plan.md` — Phần [X] liên quan
- `changelog.md` — Xem những gì đã được build

## Yêu cầu cụ thể
1. [Yêu cầu 1]
2. [Yêu cầu 2]
3. ...

## Signals liên quan (từ EventBus)
- Phát: `signal_name(params)`
- Lắng nghe: `signal_name`

## Files cần tạo/sửa
- Tạo: `scripts/autoload/xxx_manager.gd`
- Sửa: `scripts/autoload/event_bus.gd` (APPEND signal mới)

## Branch
- Tên branch: `feature/phase1-xxx`
- Base: `main`

## Definition of Done
- [ ] [Tiêu chí hoàn thành 1]
- [ ] [Tiêu chí hoàn thành 2]
- [ ] Đã chạy Self-Check Checklist (Phần 14 rulebook)
- [ ] Đã APPEND vào changelog.md
```

---

## 4. PL REVIEW CHECKLIST — Khi Agent Con hoàn thành

Khi user báo agent con đã xong, PL sẽ:

### Step 1: Scan branch
```
# PL chạy trên workspace
git diff main..feature/phase1-xxx --stat
git diff main..feature/phase1-xxx -- scripts/autoload/event_bus.gd
```

### Step 2: Automated checks
- [ ] **Golden Rule 1:** Grep tìm lời gọi trực tiếp giữa Managers
  ```
  grep -rn "NeedsManager\." scripts/ --include="*.gd" | grep -v "event_bus"
  grep -rn "GameManager\." scripts/ --include="*.gd" | grep -v "event_bus"
  ```
- [ ] **Golden Rule 2:** Grep tìm UI sửa data trực tiếp
  ```
  grep -rn "GameManager\.\|NeedsManager\." scripts/ui/ --include="*.gd"
  ```
- [ ] **Golden Rule 3:** Grep tìm inheritance sâu
  ```
  grep -rn "extends.*extends\|extends NPC\|extends Character" scripts/ --include="*.gd"
  ```
- [ ] **Golden Rule 5:** Tìm signal emit ngoài main thread
  ```
  grep -rn "EventBus\." scripts/ --include="*.gd" | grep -v "_ready\|_on_\|_emit_on_main"
  ```
- [ ] **Rule 8:** Tìm change_scene trực tiếp
  ```
  grep -rn "change_scene" scripts/ --include="*.gd" | grep -v "scene_manager"
  ```
- [ ] **Static typing:** Tìm biến/hàm thiếu type annotation
  ```
  grep -rn "var .* =" scripts/ --include="*.gd" | grep -v ": "
  ```

### Step 3: Manual review
- [ ] Đọc changelog entry mới — có đầy đủ thông tin không?
- [ ] Kiểm tra signal mới đã được thêm vào EventBus registry chưa?
- [ ] Đọc DocString của class chính — có đủ rõ ràng không?
- [ ] Architecture: module có thực sự decoupled không?

### Step 4: Verdict
- ✅ **APPROVE** → Hướng dẫn merge
- ⚠️ **REQUEST CHANGES** → Liệt kê vấn đề, user mở lại conversation agent con để fix
- ❌ **REJECT** → Liệt kê vi phạm Golden Rules, yêu cầu rewrite

---

## 5. MERGE GUIDE — Hướng dẫn merge cho user

Khi PL approve, hướng dẫn user chạy:

```powershell
# 1. Chuyển sang main
git checkout main

# 2. Pull latest main (nếu cần)
git pull origin main

# 3. Merge branch
git merge feature/phase1-xxx --no-ff -m "Merge: [TICKET-ID] — [Tên module]"

# 4. Nếu có conflict
#    PL sẽ hướng dẫn resolve từng file

# 5. Push
git push origin main

# 6. Xóa branch (tùy chọn)
git branch -d feature/phase1-xxx
```

---

## 6. PHASE 1 TASK BREAKDOWN — Foundation

Phase 1 cần được tách thành các ticket **theo dependency order**:

### Dependency Graph:
```
TICKET-001 (Project Setup + EventBus)
    │
    ├── TICKET-002 (TimeManager)
    │       │
    │       └── TICKET-005 (HUD — cần Time signals)
    │
    ├── TICKET-003 (Player + Camera + Movement)
    │       │
    │       └── TICKET-006 (TileMap District + Day/Night)
    │
    └── TICKET-004 (NeedsManager)
            │
            └── TICKET-005 (HUD — cần Needs signals)

TICKET-007 (i18n Setup) ← độc lập, chạy song song bất kỳ lúc nào
```

### Ticket summary:

| ID | Module | Dependency | Trạng thái | Ước tính |
|---|---|---|---|---|
| **T-001** | Project Setup + EventBus + GameManager | Không | ✅ Xong | 30 phút |
| **T-002** | TimeManager | T-001 | ✅ Xong | 1-2 giờ |
| **T-003** | Player + Camera + MovementComponent + FSM | T-001 | ✅ Xong | 2-3 giờ |
| **T-004** | NeedsManager (5 stats + decay logic) | T-001, T-002 | ✅ Xong | 1-2 giờ |
| **T-005** | HUD (Time display + Needs bars + Money) | T-002, T-004 | ✅ Xong | 1-2 giờ |
| **T-006** | TileMap District + Day/Night lighting | T-003 | ✅ Xong | 2-3 giờ |
| **T-007** | i18n Setup (CSV + tr() pattern) | T-001 | ✅ Xong | 30 phút |
| **T-FIX-001** | Architecture Refactoring (Save system, Reactive UI, Typings) | Các module đã code | ✅ Xong | 1-2 giờ |

---

## 6.1 PHASE 3 TASK BREAKDOWN — Social Foundation

| ID | Module | Trạng thái | Ước tính |
|---|---|---|---|
| **T-008** | NPCBase & Dialogue System | ✅ Xong | 2-3 giờ |
| **T-009** | NPC Relationship & Schedule System | ✅ Xong | 2-3 giờ |
| **T-010** | City Prologue District & One-Day Loop | ⏳ Chờ Agent làm | 3-4 giờ |

### Execution order khuyến nghị:
```
Wave 1: T-001 (phải xong trước tất cả)
Wave 2: T-002 + T-003 (song song)
Wave 3: T-004 (cần T-002)
Wave 4: T-005 + T-006 (song song, cần T-002/T-003/T-004)
Any time: T-007
```

## 7. MILESTONES CẤP BÁCH — VERTICAL SLICE A

**CẢNH BÁO QUAN TRỌNG:**
Tuyệt đối **KHÔNG** mở rộng các tính năng ngoài luồng (Quests, Farming, Phone System, v.v.) cho đến khi Vertical Slice A (City Prologue) hoàn thành.
Ngay khi ticket **T-010** được merge và Vertical Slice A có thể chơi được từ đầu đến cuối (Đi làm -> Ăn -> Ngủ -> Chuyển cảnh):
👉 **DỪNG LẠI TOÀN BỘ MỌI TÍNH NĂNG MỚI.**
👉 **YÊU CẦU USER MỞ GAME LÊN TỰ THÂN TRẢI NGHIỆM VÀ REVIEW GAMEPLAY LOOP.**
Mọi phát triển sau đó chỉ được tiến hành sau khi User xác nhận Core Loop đã "đủ hay".

---

## 8. ESCALATION POLICY — Khi có vấn đề

| Tình huống | Hành động |
|---|---|
| Agent con vi phạm Golden Rule | REJECT, yêu cầu rewrite toàn bộ phần vi phạm |
| Merge conflict nhỏ (1-2 files) | PL hướng dẫn user resolve line by line |
| Merge conflict lớn (nhiều files) | Rollback merge, PL phân tích kiến trúc và tách lại ticket |
| Agent con sửa code của module khác | Review kỹ — nếu không có lý do chính đáng → REJECT |
| Agent con thêm Autoload mới | PL verify thứ tự load, cập nhật Autoload Registry |
| Rulebook có rule mâu thuẫn thực tế | PL xác nhận với user, cập nhật rulebook, thông báo tất cả agent con |
| Agent con không ghi changelog | REJECT — bắt buộc ghi trước khi approve |

---

## 8. COMMUNICATION PROTOCOL — Giao tiếp giữa User và PL

### User → PL (Các lệnh PL hiểu):
- **"Tạo ticket cho [module]"** → PL tạo Task Prompt đầy đủ để copy/paste
- **"Agent A xong branch [tên]"** → PL bắt đầu review
- **"Merge thành công"** → PL cập nhật task tracker
- **"Có conflict"** → PL hướng dẫn resolve
- **"Agent A gặp lỗi [mô tả]"** → PL phân tích và đưa giải pháp
- **"Status"** → PL báo cáo tiến độ tổng thể

### PL → User (Output):
- **Task Prompt** (copy/paste cho agent con)
- **Review Report** (approve/reject + lý do)
- **Merge Commands** (các lệnh git cụ thể)
- **Progress Report** (task tracker cập nhật)

---

*Tài liệu này được quản lý bởi Project Lead AI. Cập nhật khi workflow thay đổi.*
