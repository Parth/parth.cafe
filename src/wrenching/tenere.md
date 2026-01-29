# 1-23-25
Picked up from Logan from a storage location in Saratoga Springs. Battery a litle low on pickup, and there's damage on the headlights. Apart from that it's in great condition. Pretty surprised I was able to grab this 25 version with new suspension and throttle tech for so cheap. 

![pasted_image_2026-01-27_03-48-10.png](imports/pasted_image_2026-01-27_03-48-10.png)

Am in search for most of the fun the CRF has given me, and also more comfort on the highway. 

# todo-now
* [x] register
* [ ] heated grips
* [ ] Clutch
* [ ] quad lock
  * [ ] maybe with [this thing](https://www.revzilla.com/motorcycle/altrider-top-clamp-system-with-amps-yamaha-tenere-700-2021-2025?sku_id=10557004&utm_source=google&utm_medium=cpc&utm_campaign=PLA-Metric%20Parts-PMAX&utm_term=go_cmp-20958281733_adg-_ad-__dev-c_ext-_prd-10557004_mca-2934692_sig-Cj0KCQiAvtzLBhCPARIsALwhxdolWfXG6ZJLXAN2k1Tf_yyA46S6sT1pNmbNBqmcBSa3CBX-8ssQ7zAaAuNwEALw_wcB&gad_source=1&gad_campaignid=20968028560&gbraid=0AAAAAD8sxezdmhMoLWG0r9kZkKeakH01u&gclid=Cj0KCQiAvtzLBhCPARIsALwhxdolWfXG6ZJLXAN2k1Tf_yyA46S6sT1pNmbNBqmcBSa3CBX-8ssQ7zAaAuNwEALw_wcB). Or [this thing](https://www.motomachines.com/evotech-performance-quad-lock-handlebar-mount-yamaha-tenere-rally-2019?utm_source=google&utm_medium=cpc&utm_campaign=18270211356&utm_content=&utm_term=&gad_source=1&gad_campaignid=18270217104&gbraid=0AAAAADuddyhb3eU9yOngf5w_cMXQkIvYA&gclid=Cj0KCQiAvtzLBhCPARIsALwhxdr7tAZrs6K6-vZycoNKqsquDtsTd17V7WPze7R6lWJo4A8EmRLcFgYaAl1FEALw_wcB)
* [ ] ask about 600 mile service
* [ ] hand guards
* [ ] oil change
* [ ] spools
* [ ] Clutch

# todo-later<!-- {"fold":true} -->
* [ ] crash bars? maybe not plastics are $300, everything else looks resiliant.
* [ ] extra wheels for knobies?

# todo much later<!-- {"fold":true} -->
<!-- {"fold":true} -->
* [ ] [plastics](https://www.tmbrmoto.com/collections/rtech/products/rtech-revolution-plastic-body-kit-2025-yamaha-tenere-700?variant=47230584488101)
    Checking workspace v26.1.29 (/home/parth/Documents/lockbook/lockbook/libs/content/workspace)
error[E0277]: `Rc<RefCell<bool>>` cannot be sent between threads safely
   --> libs/content/workspace/src/workspace.rs:904:23
    |
904 |           thread::spawn(move || {
    |  _________-------------_^
    | |         |
    | |         required by a bound introduced by this call
905 | |             let data = data.read().unwrap();
906 | |             let content = serde_json::to_string(&*data).unwrap();
907 | |             fs::write(path, content)
908 | |         });
    | |_________^ `Rc<RefCell<bool>>` cannot be sent between threads safely
    |
    = help: within `WsPresistentData`, the trait `Send` is not implemented for `Rc<RefCell<bool>>`
note: required because it appears within the type `ToolbarPersistence`
   --> libs/content/workspace/src/tab/markdown_editor/widget/toolbar.rs:44:12
    |
44  | pub struct ToolbarPersistence {
    |            ^^^^^^^^^^^^^^^^^^
note: required because it appears within the type `MdPersistence`
   --> libs/content/workspace/src/tab/markdown_editor/mod.rs:129:12
    |
129 | pub struct MdPersistence {
    |            ^^^^^^^^^^^^^
note: required because it appears within the type `WsPresistentData`
   --> libs/content/workspace/src/workspace.rs:799:8
    |
799 | struct WsPresistentData {
    |        ^^^^^^^^^^^^^^^^
    = note: required for `std::sync::RwLock<WsPresistentData>` to implement `std::marker::Sync`
    = note: required for `std::sync::Arc<std::sync::RwLock<WsPresistentData>>` to implement `Send`
note: required because it's used within this closure
   --> libs/content/workspace/src/workspace.rs:904:23
    |
904 |         thread::spawn(move || {
    |                       ^^^^^^^
note: required by a bound in `std::thread::spawn`
   --> /rustc/29483883eed69d5fb4db01964cdf2af4d86e9cb2/library/std/src/thread/mod.rs:723:1

error[E0277]: `Rc<RefCell<bool>>` cannot be shared between threads safely
   --> libs/content/workspace/src/workspace.rs:904:23
    |
904 |           thread::spawn(move || {
    |  _________-------------_^
    | |         |
    | |         required by a bound introduced by this call
905 | |             let data = data.read().unwrap();
906 | |             let content = serde_json::to_string(&*data).unwrap();
907 | |             fs::write(path, content)
908 | |         });
    | |_________^ `Rc<RefCell<bool>>` cannot be shared between threads safely
    |
    = help: within `WsPresistentData`, the trait `std::marker::Sync` is not implemented for `Rc<RefCell<bool>>`
note: required because it appears within the type `ToolbarPersistence`
   --> libs/content/workspace/src/tab/markdown_editor/widget/toolbar.rs:44:12
    |
44  | pub struct ToolbarPersistence {
    |            ^^^^^^^^^^^^^^^^^^
note: required because it appears within the type `MdPersistence`
   --> libs/content/workspace/src/tab/markdown_editor/mod.rs:129:12
    |
129 | pub struct MdPersistence {
    |            ^^^^^^^^^^^^^
note: required because it appears within the type `WsPresistentData`
   --> libs/content/workspace/src/workspace.rs:799:8
    |
799 | struct WsPresistentData {
    |        ^^^^^^^^^^^^^^^^
    = note: required for `std::sync::RwLock<WsPresistentData>` to implement `std::marker::Sync`
    = note: required for `std::sync::Arc<std::sync::RwLock<WsPresistentData>>` to implement `Send`
note: required because it's used within this closure
   --> libs/content/workspace/src/workspace.rs:904:23
    |
904 |         thread::spawn(move || {
    |                       ^^^^^^^
note: required by a bound in `std::thread::spawn`
   --> /rustc/29483883eed69d5fb4db01964cdf2af4d86e9cb2/library/std/src/thread/mod.rs:723:1

For more information about this error, try `rustc --explain E0277`.
error: could not compile `workspace` (lib) due to 2 previous errors