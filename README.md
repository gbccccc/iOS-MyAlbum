# Hackathon

iOS hackathon: MyAlbum.

演示视频：https://www.bilibili.com/video/BV1ht421H7UC

##### 功能简介

- 相册列表，可以通过本机相册或相机添加相片
- 使用 Snacks 模型识别相片并加上标签，并按标签对照片分类
- 分类界面，可以查看所有带有某一标签的图片
- 相片详情界面

##### 部分实现细节

偷了个懒，整体基于 iwork4 的代码修改，修改了选择相片后的行为，就不需要再实现一次目标识别的部分了。

相册界面采用 `ScrollView` 和两级 `StackView` 实现，可根据内容数量自适应调整高度；使用按钮作为图片缩略图，点击后会进入图片详情界面。这里本来想用 `CollectionViewController` 的，但实在没搞明白就放弃了。

使用了一个列表存储识别得到过的标签，用于在分类界面生成多个 `TableCellView` 。

相册界面带有一个 `currentTag` 属性，如果值不为 `"All"` ，加载按钮时就仅会加载标签与 `currentTag` 相同的照片，实现相册界面的代码复用。
