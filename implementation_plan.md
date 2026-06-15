# 🌆🌾 Game Design Document — Life Simulation RPG

> **Concept:** Kết hợp nền tảng pixel art tile-based của **Stardew Valley** với chiều sâu mô phỏng cuộc sống của **Nobody: The Turnaround**. Farming tồn tại như một hoạt động phụ — **core gameplay** là trải nghiệm xã hội, quản lý cuộc sống, và phát triển bản thân.

---

## Phân tích Nobody: The Turnaround

Trước khi đi vào thiết kế, đây là tóm tắt các hệ thống cốt lõi của Nobody mà ta sẽ lấy cảm hứng:

### Những gì Nobody làm tốt (Sẽ kế thừa)
| Hệ thống | Mô tả | Áp dụng cho game ta |
|---|---|---|
| **Survival Stats** | 4 chỉ số: Cool (động lực), Mood (tâm trạng), Fed (no/đói), Neatness (vệ sinh) | ✅ Giữ nguyên concept, điều chỉnh thành hệ thống Needs |
| **Job System** | Bắt đầu từ lao động chân tay → lên dần nghề tốt hơn. Mỗi nghề cần kỹ năng riêng | ✅ Hệ thống việc làm đa dạng thay vì chỉ farming |
| **Life Goals** | Mục tiêu dài hạn mở khóa tier mới (Sorryass → Nobody → Striver) | ✅ Hệ thống tiến trình cuộc sống |
| **Social/Romance** | Chat qua app, tặng quà, hẹn hò, tương tác vật lý (ôm, hôn) | ✅ Social sâu hơn Stardew |
| **Housing** | Từ ngủ đường → thuê phòng → mua nhà. Nhà ảnh hưởng stats | ✅ Housing progression |
| **Time Pressure** | Mỗi ngày có giới hạn thời gian, phải chọn ưu tiên | ✅ Quản lý thời gian mỗi ngày |
| **Random Events** | Bệnh tật, tai nạn, gặp may — cuộc sống không đoán trước | ✅ Event system ngẫu nhiên |
| **Mood Consequences** | Mood thấp → nhân vật hành xử liều lĩnh (uống rượu, đập phá) | ✅ Hành vi tự động dựa trên trạng thái |

### Những gì Stardew làm tốt (Sẽ giữ làm nền tảng)
| Hệ thống | Mô tả | Vai trò trong game ta |
|---|---|---|
| **Pixel Art 2D World** | Thế giới tile-based đẹp, ấm áp, dễ tiếp cận | ✅ Giữ nguyên — nền tảng visual |
| **Seasonal Cycle** | 4 mùa ảnh hưởng mọi thứ | ✅ Giữ nguyên |
| **Farming** | Trồng trọt, chăn nuôi | ⚠️ **Giáng cấp** thành hoạt động phụ/nghề nghiệp |
| **NPC Schedule** | NPC có lịch trình riêng, thế giới sống động | ✅ Mở rộng thêm |
| **Heart Events** | Cutscene đặc biệt khi đạt mốc thiện cảm | ✅ Giữ và mở rộng |
| **Exploration** | Nhiều khu vực khám phá | ✅ Mở rộng thành thành phố + nông thôn |

---

## Tổng quan dự án (Đã cập nhật)

| Thuộc tính | Giá trị |
|---|---|
| **Tên dự án** | `LifeSim` *(tạm thời, đặt tên chính thức sau)* |
| **Engine** | Godot 4 Standard |
| **Ngôn ngữ** | GDScript |
| **Nền tảng** | Đa nền tảng (PC → Mobile → Web) |
| **Đồ họa** | Pixel Art 32×32, Top-down 3/4 view |
| **Viewport** | 480×270 (scale x4 → 1920×1080), ~15×8 tiles visible |
| **Core Gameplay** | 🆕 **Mô phỏng cuộc sống & Xã hội** (không còn farming-centric) |
| **Bản đồ** | 🆕 **District-based (Multi-scene)** — 2 bối cảnh: Quê nhà + Thành phố |
| **Combat** | Không có |
| **Multiplayer** | Single-player trước, thiết kế sẵn sàng cho co-op |
| **Input** | Keyboard (WASD) + Mouse — cả phím và click đều tương tác được |
| **Ngôn ngữ game** | Đa ngôn ngữ (i18n) từ đầu — Tiếng Anh + Tiếng Việt |
| **Art Assets** | Asset miễn phí ban đầu, học vẽ pixel art dần, thay thế sau |
| **Version Control** | Git (GitHub/GitLab) |
| **Dev Team** | Solo developer |
| **Theme/Narrative** | ⏳ *Chưa quyết định — sẽ thiết kế riêng (cảm hứng từ FF7-10, Xenoblade trilogy)* |

---

## Vòng lặp Gameplay cốt lõi (Core Loop)

```
┌─────────────────────────────────────────────────────┐
│                    MỖI NGÀY MỚI                     │
│                  (Thức dậy 6:00)                    │
└────────────────────────┬────────────────────────────┘
                         ▼
          ┌──────────────────────────────┐
          │     QUẢN LÝ NHU CẦU         │
          │  Ăn sáng, tắm rửa, mặc đồ  │
          └──────────────┬───────────────┘
                         ▼
          ┌──────────────────────────────┐
          │     CHỌN HOẠT ĐỘNG NGÀY     │
          │                              │
          │  🔨 Đi làm (kiếm tiền)      │
          │  📚 Học tập (nâng kỹ năng)  │
          │  🌾 Farming (trồng trọt)    │
          │  🎣 Câu cá / Thu hái        │
          │  🛒 Mua sắm / Nấu ăn       │
          │  🏠 Trang trí nhà           │
          │  🗺️ Khám phá thế giới      │
          └──────────────┬───────────────┘
                         ▼
          ┌──────────────────────────────┐
          │     TƯƠNG TÁC XÃ HỘI        │
          │                              │
          │  💬 Nói chuyện với NPC       │
          │  🎁 Tặng quà               │
          │  📱 Chat qua điện thoại     │
          │  ☕ Đi cafe / ăn tối cùng   │
          │  ❤️ Hẹn hò                 │
          │  🎉 Tham gia sự kiện        │
          └──────────────┬───────────────┘
                         ▼
          ┌──────────────────────────────┐
          │      BUỔI TỐI                │
          │                              │
          │  🌙 Giải trí (game, TV, đọc)│
          │  🍺 Quán bar / câu lạc bộ   │
          │  📱 Chat đêm với bạn bè     │
          │  😴 Đi ngủ → Kết thúc ngày  │
          └──────────────┬───────────────┘
                         ▼
          ┌──────────────────────────────┐
          │     KẾT QUẢ CUỐI NGÀY       │
          │                              │
          │  💰 Tổng thu nhập            │
          │  📊 Stats thay đổi           │
          │  📈 Kỹ năng tăng            │
          │  ❤️ Quan hệ phát triển      │
          │  ⭐ Life Goal tiến trình     │
          │  🎲 Random Event xảy ra?     │
          │  💾 Auto-save                │
          └──────────────────────────────┘
```

---

## Hệ thống chi tiết

### 1. 🧠 Hệ thống Nhu cầu (Needs System) — *Lấy từ Nobody*

Thay vì chỉ có Energy (Stardew), game có **5 chỉ số nhu cầu** ảnh hưởng trực tiếp đến gameplay:

| Chỉ số | Ý nghĩa | Tăng bằng | Giảm khi | Hậu quả khi thấp |
|---|---|---|---|---|
| **Mood** 😊 | Tâm trạng | Giải trí, giao lưu, ăn ngon, thành tựu | Làm việc nặng, bị từ chối, cô đơn, đói | Hành vi tiêu cực tự động, NPC phản ứng xấu |
| **Energy** ⚡ | Thể lực | Ngủ, nghỉ ngơi, ăn uống | Làm việc, di chuyển nhiều, thức khuya | Không thể làm việc, ngất xỉu |
| **Hunger** 🍽️ | No/Đói | Ăn uống | Theo thời gian | Mất Energy nhanh, Mood giảm, bệnh |
| **Hygiene** 🚿 | Vệ sinh | Tắm rửa, giặt đồ | Theo thời gian, làm việc bẩn | NPC xa lánh, không được vào nơi sang |
| **Social** 💬 | Nhu cầu xã hội | Trò chuyện, tham gia sự kiện | Ở một mình lâu | Mood giảm dần, cô đơn |

> [!IMPORTANT]
> **Khác biệt lớn với Stardew:** Nhân vật không chỉ mệt → game giả lập cả tâm lý và xã hội. Mood thấp quá có thể dẫn đến nhân vật **tự động** uống rượu, bỏ việc, hoặc cãi nhau với NPC (giống Nobody).

### 2. 💼 Hệ thống Việc làm (Job System) — *MỚI, lấy từ Nobody*

Thay vì chỉ farming, người chơi có **nhiều nghề nghiệp** để kiếm sống:

#### Tier 1: Lao động phổ thông (Không cần kỹ năng)
- 🧹 Dọn dẹp / Phục vụ quán
- 📦 Bốc vác / Giao hàng
- 🌾 Làm thuê nông trại (farming ở đây!)
- 🗑️ Thu gom phế liệu

#### Tier 2: Có kỹ năng cơ bản
- 🍳 Phụ bếp → Đầu bếp
- 🏪 Nhân viên cửa hàng
- 🎣 Ngư dân
- 🔨 Thợ thủ công

#### Tier 3: Chuyên nghiệp (Cần chứng chỉ/học tập)
- 🏫 Giáo viên
- 🏥 Y tá / Dược sĩ
- 📰 Nhà báo / Nhà văn
- 🎨 Nghệ sĩ

#### Tier 4: Tự kinh doanh
- 🏡 Mở trang trại riêng (farming trở lại ở đây!)
- 🍰 Mở quán cafe / nhà hàng
- 🏪 Mở cửa hàng riêng
- 🎓 Mở trường dạy nghề

> **Farming trong context mới:** Farming không biến mất — nó là MỘT trong nhiều con đường nghề nghiệp. Có thể bắt đầu làm thuê trang trại (Tier 1) → tích lũy → mở trang trại riêng (Tier 4).

### 3. 📈 Hệ thống Kỹ năng & Phát triển (Skill & Progression)

**4 nhóm kỹ năng chính** (lấy cảm hứng từ Nobody):

| Nhóm | Mô tả | Ảnh hưởng | Nâng cấp bằng |
|---|---|---|---|
| **Strength** 💪 | Sức mạnh thể chất | Công việc chân tay, farming, năng suất | Làm việc tay chân, tập gym |
| **Intelligence** 🧠 | Trí tuệ | Nghề chuyên môn, học nhanh, giải quyết vấn đề | Đọc sách, đi học, nghiên cứu |
| **Charisma** ✨ | Sức hút xã hội | Quan hệ NPC, thương lượng giá, mở khóa hội thoại | Giao tiếp, giúp đỡ NPC |
| **Dexterity** 🎯 | Khéo léo | Câu cá, thủ công, nấu ăn, nghệ thuật | Thực hành các hoạt động liên quan |

**Life Goals** (tiến trình cuộc sống):
```
Newcomer (Người mới) → Settler (Định cư) → Citizen (Công dân) 
→ Respected (Được trọng) → Leader (Thủ lĩnh cộng đồng)
```
Mỗi tier mở khóa: nghề mới, khu vực mới, NPC mới, tùy chọn hội thoại mới.

### 4. 🏠 Hệ thống Nhà ở (Housing System) — *MỚI, lấy từ Nobody*

Tiến trình nhà ở ảnh hưởng trực tiếp đến chất lượng cuộc sống:

| Cấp | Loại | Chi phí | Tiện ích | Ảnh hưởng Stats |
|---|---|---|---|---|
| 0 | 🏕️ Lều / Ngủ ngoài trời | Miễn phí | Không có gì | Hygiene −−, Mood −−, bị bệnh |
| 1 | 🛏️ Phòng trọ chia sẻ | Rẻ / ngày | Giường, nước | Hygiene +, Mood − |
| 2 | 🏠 Thuê phòng riêng | Vừa / tháng | Giường, bếp, tắm | Hygiene ++, Mood + |
| 3 | 🏡 Mua nhà nhỏ | Đắt (mua đứt) | Đầy đủ, trang trí được | Hygiene +++, Mood ++, nấu ăn |
| 4 | 🏘️ Nâng cấp / Mở rộng | Rất đắt | Vườn riêng, phòng khách, bếp lớn | Mọi stats ++, farming tại nhà |

> **Trang trí nhà:** Người chơi có thể mua/craft đồ nội thất, thay đổi bố trí phòng — ảnh hưởng Mood bonus.

### 5. 👥 Hệ thống NPC & Xã hội (Social System) — *Mở rộng sâu*

Đây là **core system** — sâu hơn nhiều so với Stardew:

#### Tương tác NPC đa dạng:
| Hành động | Yêu cầu | Hiệu ứng |
|---|---|---|
| 💬 Nói chuyện | Bất kỳ | +1 Friendship, +Social need |
| 🎁 Tặng quà | Có vật phẩm phù hợp | +3-10 Friendship tùy món quà |
| 📱 Chat qua app | Có số điện thoại NPC | +Friendship, +Mood (mini-game chọn chủ đề) |
| ☕ Mời đi cafe/ăn | Đủ tiền, Friendship ≥ 3 | ++Friendship, mở khóa dialogue mới |
| 🤝 Giúp đỡ (quest) | NPC giao nhiệm vụ | +++Friendship, phần thưởng |
| 🎉 Tham gia sự kiện cùng | Sự kiện đang diễn ra | Friendship + tùy kết quả |
| ❤️ Hẹn hò | Friendship ≥ 6, item đặc biệt | Chuyển sang Romance track |
| 🫂 Ôm / Hôn | Romance partner | +Mood lớn cho cả 2 |
| 🏠 Mời về nhà | Friendship ≥ 8, có nhà | Cutscene đặc biệt |

#### Hệ thống quan hệ nhiều tầng:
```
Stranger → Acquaintance → Friend → Close Friend → Best Friend
                                  ↘ Romantic Interest → Partner → Spouse
```

#### NPC có "cuộc sống riêng":
- Mỗi NPC có lịch trình riêng theo giờ/ngày/mùa
- NPC phản ứng theo thời tiết (mưa → ở nhà)
- NPC nhớ hành động của người chơi (tặng quà gì, bỏ hẹn, v.v.)
- NPC có quan hệ với nhau (NPC A ghét NPC B → tặng quà A trước mặt B sẽ giảm điểm B)
- NPC có personality traits ảnh hưởng dialogue

### 6. ⏰ Hệ thống Thời gian (Đã cập nhật)
- Mỗi ngày in-game = ~20 phút thực
- 6:00 AM → 2:00 AM (thức khuya = Energy hôm sau giảm)
- **4 mùa × 28 ngày = 112 ngày/năm** *(đổi từ 30 → 28 ngày cho đúng 4 tuần/mùa)*
- **Lịch tuần:** Thứ 2-6 (ngày thường: làm việc/học), Thứ 7-CN (cuối tuần: NPC nghỉ, sự kiện xã hội, chợ phiên)
- Thời gian dừng khi mở menu/dialogue
- Một số việc/sự kiện chỉ có vào ngày cụ thể trong tuần

### 7. 🌦️ Hệ thống Thời tiết (Giữ nguyên)
- Nắng, Mưa, Bão, Tuyết (theo mùa)
- Ảnh hưởng: NPC schedule, việc ngoài trời, mood, cây trồng

### 8. 🌾 Hệ thống Farming (Giáng cấp thành Side Activity)

Farming **không biến mất** nhưng thay đổi vai trò:
- **Không bắt buộc** — chỉ là MỘT cách kiếm tiền/thực phẩm
- Có thể farming tại: vườn nhà (nếu có nhà cấp 4), trang trại thuê, trang trại riêng
- Cơ chế farming giống Stardew: cuốc → gieo → tưới → thu hoạch
- Nông sản có thể: bán, nấu ăn, tặng NPC, chế biến
- **Có thể thuê NPC làm thay** nếu đủ tiền (tự động hóa)

### 9. 🗺️ Thế giới game (District-based / Multi-scene)

Thế giới chia thành **2 bối cảnh lớn**, mỗi bối cảnh gồm nhiều **district (scene)** riêng biệt. Chuyển cảnh giữa các district bằng cổng/cửa/ranh giới (fade transition). Chuyển giữa 2 bối cảnh bằng phương tiện giao thông (xe bus/tàu — cutscene ngắn).

**Kiến trúc map:**
- Mỗi district = 1 file `.tscn` riêng biệt trong Godot
- Chỉ load 1 district tại 1 thời điểm → tối ưu bộ nhớ
- `SceneManager.gd` (Autoload) quản lý chuyển cảnh, lưu trạng thái district cũ
- Transition effects: fade to black, slide, hoặc cutscene

```
🏡 QUÊ NHÀ (Hometown — Tuổi thơ & Nostalgia)
│   Bối cảnh nhỏ, ấm áp, gần gũi thiên nhiên
│
├── home_house.tscn          — Nhà gia đình, vườn nhỏ
├── home_village.tscn         — Làng xóm, hàng xóm, chợ phiên
├── home_fields.tscn          — Cánh đồng, trang trại, farming chính
├── home_forest.tscn          — Rừng, sông, câu cá, hái lượm
└── home_school.tscn          — Trường học (giai đoạn tuổi thơ)

    🚌 CHUYỂN CẢNH — Xe bus / Tàu hỏa (cutscene, tốn 1 ngày)

🌆 THÀNH PHỐ (City — Cuộc đời trưởng thành)
│   Bối cảnh lớn, nhộn nhịp, nhiều cơ hội và thử thách
│
├── city_residential.tscn     — Khu dân cư, nhà trọ, căn hộ
├── city_downtown.tscn        — Trung tâm, quảng trường, tòa thị chính
├── city_commercial.tscn      — Khu thương mại, cửa hàng, siêu thị
├── city_industrial.tscn      — Khu công nghiệp, việc làm tay chân
├── city_education.tscn       — Trường đại học, thư viện, trung tâm dạy nghề
├── city_entertainment.tscn   — Công viên, quán bar, rạp phim, phòng gym
├── city_harbor.tscn          — Bến cảng, bãi biển, chợ cá
├── city_hospital.tscn        — Bệnh viện, phòng khám
└── city_suburbs.tscn         — Ngoại ô, trang trại gần thành phố
```

> **Quay về quê:** Người chơi có thể quay về quê thăm nhà bất cứ lúc nào (tốn 1 ngày di chuyển). Quê nhà thay đổi theo mùa và theo tiến trình game — tạo cảm xúc nostalgia.

> **Mở rộng sau:** Có thể thêm bối cảnh thứ 3 (VD: thị trấn ven biển, vùng núi) bằng cách thêm scene mới mà không cần sửa hệ thống cũ.

### 10. 🎲 Hệ thống Sự kiện ngẫu nhiên (Random Events) — *MỚI*
Mỗi ngày có xác suất xảy ra các sự kiện:
- **Tích cực:** Tìm được tiền, NPC mời ăn, bonus công việc, giảm giá cửa hàng
- **Tiêu cực:** Bị bệnh, mất đồ, trời mưa hỏng kế hoạch, tăng giá thuê nhà
- **Trung lập:** Gặp NPC mới, phát hiện địa điểm mới, tin tức ảnh hưởng kinh tế
- **Seasonal Events:** Lễ hội, thi đấu, hội chợ — mỗi mùa có sự kiện riêng

### 11. 📱 Hệ thống Điện thoại (Phone System) — *MỚI, lấy từ Nobody*
Nhân vật có điện thoại di động để:
- 📱 Chat với NPC đã kết bạn (mini-game chọn chủ đề)
- 📋 Xem bảng việc làm / tuyển dụng
- 📰 Đọc tin tức (ảnh hưởng sự kiện)
- 🗺️ Xem bản đồ
- ⏰ Đặt báo thức
- 📷 Chụp ảnh (album kỷ niệm)

### 12. 💰 Hệ thống Kinh tế (Economy)
- Tiền tệ: Gold (G)
- Thu nhập: Lương việc làm, bán nông sản/cá/đồ craft, hoàn thành quest
- Chi phí: Thuê nhà, ăn uống, quần áo, giáo dục, giải trí, quà tặng
- Giá biến động theo mùa và sự kiện
- **MỚI:** Hệ thống nợ/vay (tùy chọn, không bắt buộc như Nobody)

### 13. 💾 Save/Load System
- Auto-save cuối ngày (khi đi ngủ)
- 3-5 slot lưu thủ công
- Lưu toàn bộ trạng thái game

### 14. 🎮 Hệ thống Điều khiển (Controls)
- **Di chuyển:** WASD hoặc Arrow keys (8 hướng)
- **Tương tác:** Phím E/Space HOẶC click chuột vào đối tượng
- **Toolbar:** Tab hoặc phím số 1-9 để chọn nhanh
- **Menu:** I (Inventory), P (Phone), M (Map), Esc (Pause)
- **Mouse:** Click chuột trái = tương tác/sử dụng, Click phải = xem thông tin
- Hỗ trợ cả Keyboard-only và Mouse-only gameplay

### 15. 🌍 Hệ thống Đa ngôn ngữ (i18n/Localization)
- Thiết kế i18n từ đầu — tất cả text UI và dialogue qua translation keys
- Sử dụng Godot built-in Translation system (`.csv` hoặc `.po` files)
- **Ngôn ngữ khởi đầu:** Tiếng Anh (EN) + Tiếng Việt (VI)
- Cấu trúc: `data/locales/en.csv`, `data/locales/vi.csv`
- Không hard-code text trong scripts — luôn dùng `tr("KEY")`

### 16. 🎵 Hệ thống Âm thanh (Audio Direction)
- **Quê nhà:** Nhạc acoustic/guitar nhẹ nhàng, tiếng chim, gió, suối
- **Thành phố:** Nhạc jazz/lo-fi/piano, tiếng xe cộ, đông đúc
- **Mỗi mùa** có biến thể nhạc riêng (cùng melody, khác nhạc cụ/tempo)
- **Mỗi district** có ambient sound riêng
- SFX: Bước chân, tương tác, UI feedback, thời tiết

### 17. 📍 Nội dung theo Bối cảnh (Location-specific Content)

#### Việc làm theo bối cảnh:
| Quê nhà | Thành phố |
|---|---|
| 🌾 Farming (nghề chính ở quê) | 📦 Lao động phổ thông (Tier 1) |
| 🎣 Câu cá | 🍳 Nhà hàng/Cafe (Tier 2) |
| 🪵 Thợ mộc / Thủ công | 🏪 Bán hàng / Văn phòng (Tier 2-3) |
| 🏪 Buôn bán nhỏ / Chợ phiên | 🏫 Chuyên nghiệp (Tier 3) |
| 🐄 Chăn nuôi | 🏢 Tự kinh doanh (Tier 4) |

#### NPC theo bối cảnh:
- **Quê:** NPC gia đình, hàng xóm, bạn thời thơ — ít nhưng sâu
- **Thành phố:** NPC đồng nghiệp, hàng xóm mới, bạn mới — đông và đa dạng
- **NPC di chuyển:** Một số NPC xuất hiện ở cả 2 nơi (VD: bạn thời thơ cũng lên thành phố)

#### Nhà ở theo bối cảnh:
- **Quê:** Nhà gia đình (miễn phí, luôn có sẵn)
- **Thành phố:** Bắt đầu từ thuê trọ → mua nhà riêng (housing progression)

---

## 🏗️ Tiêu chuẩn Kiến trúc Kỹ thuật (Chống Spaghetti Code)

Để đảm bảo dự án có thể scale lên hàng chục nghìn dòng code mà không bị dính chùm logic (spaghetti), game áp dụng nghiêm ngặt các quy chuẩn sau:

### 1. Kiến trúc Giao tiếp: Event Bus (Signal Hub)
- Sử dụng duy nhất 1 Autoload `EventBus.gd` làm trạm trung chuyển signal.
- **Rule:** Các hệ thống (Manager) KHÔNG bao giờ gọi trực tiếp nhau. (Ví dụ: `InventoryManager` không được gọi `NeedsManager.add_energy()`).
- **Thay vào đó:** Emit signal (`EventBus.item_consumed.emit(item)`), và `NeedsManager` tự lắng nghe signal đó để xử lý. Decoupling tuyệt đối.

### 2. Quản lý Dữ liệu Tĩnh: Custom Resources (`.tres`)
- KHÔNG dùng file `.json` cho dữ liệu tĩnh của game (Items, Jobs, NPC Profiles).
- Sử dụng Custom Godot Resources. Tận dụng sức mạnh Type-safe và Inspector của Godot Editor để edit trực tiếp (kéo thả icon, chọn model). Load nhanh và ít rủi ro parse lỗi hơn JSON.

### 3. Kiến trúc Thực thể (Entities): Component-based FSM
- Sử dụng mô hình **Composition (Component Node)** kết hợp **FSM (Finite State Machine)** cho Player và NPC.
- **Rule:** Không dùng inheritance sâu (`Character` -> `NPC` -> `Merchant`). Thay vào đó, tạo một node trống và gắn các node Component con (như `MovementComponent`, `InteractableComponent`, `State_Idle`, `State_Walk`).

### 4. Kiến trúc Giao diện (Reactive UI)
- UI chỉ đóng vai trò View (Hiển thị).
- **Rule:** Script của UI KHÔNG bao giờ chứa logic xử lý thay đổi dữ liệu game. UI chỉ nhận user input (click nút) → Emit EventBus Signal → Logic Manager xử lý → Logic Manager Emit Update Signal → UI Update.
- Tránh việc UI bị gắn chặt vào code Backend.

### 5. Hệ thống Lưu trữ (Save/Load): Serialized JSON
- Dữ liệu Save động (vị trí đồ đạc, relationship, tiền bạc) sẽ được duyệt qua cấu trúc Dictionary và serialize ra JSON.
- An toàn, ổn định, tránh corrupt file save kiểu object dump.

---

## Cấu trúc dự án Godot 4 (Đã cập nhật chuẩn kỹ thuật)

```
game/
├── project.godot
├── assets/
│   ├── sprites/
│   │   ├── player/           # Player sprite sheets
│   │   ├── npcs/             # NPC sprite sheets
│   │   ├── crops/            # Cây trồng (side content)
│   │   ├── items/            # Vật phẩm icons
│   │   ├── buildings/        # Tòa nhà, cửa hàng
│   │   └── furniture/        # Nội thất trang trí
│   ├── tilesets/
│   ├── ui/
│   ├── audio/
│   └── fonts/
├── scenes/
│   ├── main/
│   │   ├── Main.tscn
│   │   └── GameWorld.tscn
│   ├── player/
│   │   └── Player.tscn
│   ├── ui/
│   │   ├── HUD.tscn           # Giờ, stats bars, tiền
│   │   ├── PhoneUI.tscn       # 🆕 Giao diện điện thoại
│   │   ├── InventoryUI.tscn
│   │   ├── DialogueBox.tscn
│   │   ├── JobBoardUI.tscn    # 🆕 Bảng việc làm
│   │   ├── ShopUI.tscn
│   │   ├── NeedsPanel.tscn    # 🆕 Panel hiển thị 5 nhu cầu
│   │   ├── RelationshipUI.tscn # 🆕 Danh sách quan hệ
│   │   ├── MainMenu.tscn
│   │   └── CharacterCreator.tscn
│   ├── world/
│   │   ├── hometown/              # 🆕 District-based
│   │   │   ├── home_house.tscn
│   │   │   ├── home_village.tscn
│   │   │   ├── home_fields.tscn
│   │   │   ├── home_forest.tscn
│   │   │   └── home_school.tscn
│   │   ├── city/                  # 🆕 District-based
│   │   │   ├── city_residential.tscn
│   │   │   ├── city_downtown.tscn
│   │   │   ├── city_commercial.tscn
│   │   │   ├── city_industrial.tscn
│   │   │   ├── city_education.tscn
│   │   │   ├── city_entertainment.tscn
│   │   │   ├── city_harbor.tscn
│   │   │   ├── city_hospital.tscn
│   │   │   └── city_suburbs.tscn
│   │   └── transitions/           # 🆕 Chuyển cảnh
│   │       └── bus_travel.tscn
│   ├── npcs/
│   │   ├── NPCBase.tscn
│   │   └── ...
│   └── objects/
│       ├── Crop.tscn
│       ├── Furniture.tscn     # 🆕
│       ├── Workstation.tscn   # 🆕 Nơi làm việc
│       └── ...
├── scripts/
│   ├── autoload/
│   │   ├── GameManager.gd
│   │   ├── TimeManager.gd
│   │   ├── WeatherManager.gd
│   │   ├── NeedsManager.gd    # 🆕 Quản lý 5 chỉ số nhu cầu
│   │   ├── JobManager.gd      # 🆕 Quản lý việc làm
│   │   ├── EconomyManager.gd  # 🆕 Quản lý tài chính
│   │   ├── EventManager.gd    # 🆕 Random events
│   │   ├── SaveManager.gd
│   │   ├── InventoryManager.gd
│   │   ├── EventBus.gd
│   │   └── AudioManager.gd
│   ├── player/
│   │   ├── player_controller.gd
│   │   ├── player_animation.gd
│   │   ├── player_needs.gd    # 🆕
│   │   ├── player_skills.gd   # 🆕
│   │   └── tool_handler.gd
│   ├── world/
│   │   ├── scene_manager.gd       # 🆕 Thay chunk_manager
│   │   ├── district_data.gd       # 🆕 Lưu trạng thái mỗi district
│   │   ├── transition_handler.gd  # 🆕 Hiệu ứng chuyển cảnh
│   │   └── tile_interaction.gd
│   ├── farming/               # Giáng cấp thành sub-system
│   │   ├── crop.gd
│   │   ├── soil.gd
│   │   └── farming_system.gd
│   ├── jobs/                  # 🆕
│   │   ├── job_base.gd
│   │   ├── job_database.gd
│   │   └── work_minigame.gd
│   ├── social/                # 🆕 Mở rộng
│   │   ├── npc_base.gd
│   │   ├── npc_schedule.gd
│   │   ├── npc_memory.gd      # NPC nhớ hành vi player
│   │   ├── dialogue_system.gd
│   │   ├── relationship_system.gd
│   │   ├── phone_chat.gd      # 🆕
│   │   └── romance_system.gd  # 🆕
│   ├── housing/               # 🆕
│   │   ├── housing_system.gd
│   │   └── furniture_system.gd
│   └── ui/
│       ├── hud.gd
│       ├── phone_ui.gd        # 🆕
│       ├── inventory_ui.gd
│       └── dialogue_ui.gd
├── data/                  # 🆕 All data uses Custom Resources (.tres)
│   ├── items/
│   ├── jobs/                  
│   │   ├── hometown_jobs.tres 
│   │   ├── tier1_jobs.tres
│   │   ├── tier2_jobs.tres
│   │   ├── tier3_jobs.tres
│   │   └── tier4_jobs.tres
│   ├── npcs/
│   │   ├── profiles.tres
│   │   ├── dialogues/
│   │   ├── schedules/
│   │   └── gifts.tres         
│   ├── locales/               # 🆕 i18n
│   │   ├── en.csv
│   │   └── vi.csv
│   ├── events/                
│   ├── housing/               
│   ├── recipes/
│   └── world/
├── .gitignore                 # 🆕 Git ignore file
└── addons/
```

---

## Lộ trình phát triển (Đã cập nhật — 6 Phases)

### Phase 1: Foundation 🏗️ *(Bắt đầu ngay)*
> Mục tiêu: Nhân vật di chuyển trong thế giới, có chu kỳ ngày/đêm và hệ thống nhu cầu cơ bản

- [x] Setup Godot 4 project + Git repo + `.gitignore`
- [x] Cấu hình viewport 480×270, pixel perfect rendering
- [x] `EventBus.gd` — Signal hub cho toàn bộ hệ thống
- [x] `TimeManager.gd` — Đồng hồ, ngày, tuần (T2-CN), mùa, năm (28 ngày/mùa)
- [x] `NeedsManager.gd` — 5 chỉ số nhu cầu (Mood, Energy, Hunger, Hygiene, Social)
- [x] Player scene — Di chuyển 8 hướng (WASD), tương tác (E + Click)
- [x] TileMap cơ bản — 1 district đơn giản (home_village hoặc city_residential)
- [x] Camera follow player
- [x] HUD — Giờ, ngày/thứ, mùa, 5 thanh nhu cầu, tiền
- [x] Hiệu ứng ánh sáng ngày/đêm
- [x] i18n setup — Translation system cơ bản (`tr()` function, `en.csv` + `vi.csv`)

### Phase 2: Life Simulation Core 🧑‍💼
> Mục tiêu: Có thể kiếm tiền, ăn uống, ngủ nghỉ — vòng lặp sinh tồn cơ bản

- [ ] `JobManager.gd` — Hệ thống việc làm (2-3 job Tier 1)
- [x] `EconomyManager.gd` — Tiền, mua/bán cơ bản (Được gộp vào GameManager)
- [x] Housing cơ bản — Thuê phòng trọ vs ngủ ngoài trời
- [x] Cửa hàng thực phẩm — Mua đồ ăn
- [x] Hệ thống ăn uống → ảnh hưởng Hunger, Energy
- [x] Hệ thống ngủ → kết thúc ngày, phục hồi Energy
- [x] Inventory cơ bản — Toolbar + Backpack

### Phase 3: Social Foundation 👥
> Mục tiêu: NPC sống động, nói chuyện được, tặng quà, bắt đầu xây dựng quan hệ

- [ ] `NPCBase` — NPC đi lại theo lịch trình
- [ ] Dialogue system — Hội thoại phân nhánh
- [ ] Relationship system — Friendship points, tặng quà
- [ ] 5 NPC đầu tiên với personality, schedule, dialogue
- [ ] Phone system cơ bản — Chat với NPC đã kết bạn
- [ ] `NeedsManager` update — Social need tăng/giảm

### Phase 4: World Expansion & Activities 🗺️
> Mục tiêu: Thế giới rộng hơn, nhiều hoạt động hơn

- [ ] `SceneManager.gd` — Quản lý chuyển district, lưu trạng thái
- [ ] `TransitionHandler.gd` — Fade, slide, cutscene transitions
- [ ] Build thêm districts: Hometown (home_forest, home_fields)
- [ ] Build thêm districts: City (city_entertainment, city_harbor)
- [ ] Hệ thống di chuyển giữa Quê ↔ Thành phố (xe bus cutscene)
- [ ] Farming system (side activity) — Vườn nhà hoặc trang trại quê
- [ ] Fishing system
- [ ] Thêm jobs Tier 2-3
- [ ] Skill progression system
- [ ] Random events system
- [ ] Weather system + ảnh hưởng gameplay

### Phase 5: Deep Social & Content ❤️
> Mục tiêu: Hệ thống xã hội hoàn chỉnh, nhiều NPC, sự kiện

- [ ] Romance system — Hẹn hò, cầu hôn, kết hôn
- [ ] Heart events (cutscenes tại mốc friendship)
- [ ] NPC memory system — NPC nhớ hành vi player
- [ ] NPC-NPC relationships
- [ ] Life Goals system — Tiến trình cuộc sống
- [ ] Thêm 10+ NPC
- [ ] Seasonal festivals
- [ ] Housing decoration system
- [ ] Cooking & Crafting

### Phase 6: Polish & Expansion 🚀
> Mục tiêu: Game hoàn chỉnh, ready to ship

- [ ] Thêm thị trấn/vùng đất mới
- [ ] Jobs Tier 4 — Tự kinh doanh
- [ ] Full audio (BGM + SFX)
- [x] Save/Load hoàn chỉnh
- [ ] Main menu, character creator
- [ ] Balancing & Playtesting
- [ ] Performance optimization
- [ ] Multiplayer prep architecture
- [ ] Export PC/Mobile/Web

---

## So sánh: Stardew vs Nobody vs Game của bạn

| Feature | Stardew Valley | Nobody: The Turnaround | **Game của bạn** |
|---|---|---|---|
| Core | Farming | Survival/Life sim | **Social Life Sim** |
| Graphics | 2D Pixel Art | 3D Realistic | **2D Pixel Art** |
| Combat | Có (Mine) | Không | **Không** |
| Farming | Core gameplay | Không | **Side activity** |
| Jobs | Chỉ farming | Nhiều tier | **Nhiều tier** ✅ |
| Social | Friendship + Marriage | Romance + Chat app | **Deep social** ✅ |
| Housing | 1 nhà, upgrade | Progression (đường → nhà) | **Progression** ✅ |
| Needs | Energy only | 4 stats | **5 stats** ✅ |
| Mood system | Không | Có (hậu quả tiêu cực) | **Có** ✅ |
| Phone/App | Không | WasApp chatting | **Phone system** ✅ |
| Random Events | Ít | Nhiều | **Nhiều** ✅ |
| World | Nhỏ, map riêng | Thành phố 3D | **2 bối cảnh, district-based** ✅ |

---

## User Review Required

> [!IMPORTANT]
> **Map system đã chuyển từ Chunk-based → District-based (Multi-scene).** Mỗi khu vực là 1 scene Godot riêng biệt. Phù hợp hơn cho cấu trúc 2 bối cảnh (Quê nhà + Thành phố) và đơn giản hơn để implement.

> [!WARNING]
> **Scope vẫn lớn cho solo dev.** Gợi ý: Phase 1-3 chỉ cần 2-3 districts (1 hometown + 1-2 city) để test core mechanics. Mở rộng thêm districts ở Phase 4+.

## Open Questions

1. **⏳ Theme/Narrative Design** — Cần session riêng để thiết kế bối cảnh, cốt truyện, tone game. Cảm hứng từ FF7-10 và Xenoblade trilogy. Sẽ tham khảo thủ pháp nghệ thuật xây dựng bối cảnh và sáng tạo kịch bản.
2. **⏳ Cấu trúc cốt truyện mở đầu** — Bắt đầu từ tuổi thơ hay từ thành phố? Phụ thuộc vào thiết kế narrative.
3. **⏳ Tên dự án chính thức** — Hiện dùng tên tạm `LifeSim`.

---

## Verification Plan

### Phase 1 Verification:
- Nhân vật di chuyển mượt 8 hướng (WASD + Arrow) ✓
- Tương tác bằng cả phím E và click chuột ✓
- 5 thanh nhu cầu hiển thị và thay đổi theo thời gian ✓
- Đồng hồ chạy đúng tốc độ (20 phút/ngày) ✓
- Lịch tuần hiển thị đúng (T2-CN, 28 ngày/mùa) ✓
- Ánh sáng ngày/đêm thay đổi ✓
- Chuyển mùa sau 28 ngày ✓
- HUD hiển thị đầy đủ thông tin ✓
- i18n hoạt động — chuyển được EN ↔ VI ✓
- Git repo hoạt động, có initial commit ✓
