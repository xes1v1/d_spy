d_spy是针对DStack混合栈解决方案编写的可视化插件，其编写目的是为了在`测试环境`下，帮助使用DStack的开发者`可视化的排查节点信息`。
如果还不了解DStack混合栈解决方案，可以在[pub.dev](https://pub.dev/packages/d_stack)上进行查看。

* 在使用DStack的过程中，可能遇到由于节点异常导致的混合栈跳转错误，使用者看到界面跳转异常的时候，往往`不清楚哪里出了异常`，因为异常信息可能在最近几次页面跳转之前就已经产生。
* 用户将异常信息反馈给DStack开发人员的时候，由于缺乏异常上下文信息，也`很难进行问题场景跟进`。
* 此外由于节点管理的详细信息在Native侧进行输出，在Flutter侧运行代码`看不到全部的节点信息`，即使在Native侧查看节点信息，在众多的打印中查找也存在一定难度。

为了解决以上痛点，也即是可视化Spy插件开发的初衷。Spy插件现在具备以下特点：

* `便捷集成`：插件以Plugin和命令行的形式提供，只需少量配置即可添加可视化功能。
* `节点可视化`：用户可以实时的看到操作的每个页面对应的节点信息，方便排查问题。
* `截屏`：截取当前APP页面，和节点可视化信息一起展示，对于使用者排查问题更直观。

此外可扩展【`回放功能`】，基于Spy将用户的每个操作信息存储下来，或者用户也可以通过DStack的DNodeObserver自己记录节点操作信息，存储下来的记录支持导出，之后可以根据导出的信息回放用户的每一次界面操作。

#### 实现原理
DStack对开发者暴露了`nodeObserver:`api，在初始化DStack时可以添加节点监听。`nodeObserver:` 参数是实例化的`DNodeObserver`对象，这个类里提供`void operationNode(Map node)`Api，用户的所有操作页面对应的节点，都将通过此方法对外回调。d_spy即是通过这个回调实现的节点可视化，d_spy有两个部分组成:plugin插件`d_spy`和终端工具`dstackspy`。

* d_spy是集成到用户工程中的插件，建议在测试环境下帮助排查节点异常问题时使用。
* dstackspy是在终端运行的，为可视化页面提供支持程序，包含socket server和web页面支持。

d_spy插件将监听到的用户操作信息，通过socket传递给web侧，web侧进行节点处理后，可视化的展示栈里的节点，当用户发现页面异常的时候，通过可视化的节点信息，能够更加直观的发现问题，或者将节点信息发给DStack的开发者处理。

当然除了可以基于web页面实现回放，也可以运行一个应用程序来做可视化侧载体，只要能够接收到节点信息并方便查看即可。

`混合栈DStack和可视化插件都已经开源`
DSatck地址：[https://pub.dev/packages/d_stack ](https://pub.dev/packages/d_stack )
dstackspy地址：[https://pub.dev/packages/dstackspy](https://pub.dev/packages/dstackspy)
d_spy plugin插件地址：[https://pub.dev/packages/d_spy](https://pub.dev/packages/d_spy)
dstackspy中包含的web页面工程地址：[https://github.com/xes1v1/d_spy_web](https://github.com/xes1v1/d_spy_web)

#### 使用

1. 首先集成dstackspy终端工具
   
```
pub global activate dstackspy
```
  ![pub global activate dstackspy](https://raw.githubusercontent.com/whqfor/sources/master/blog/spy/dstackspy.png)
   
2. 启动dstackspy 

首先启动dstackspy 的webSocket默认端ip是`0.0.0.0`，端口号是`9223`，启动后需要用户手动配置webSocket地址

```
// 修改ip
dstackspy -h <自己的ip地址>
// 如果要修改端口号
dstackspy -h <自己的ip地址> -p <自定义端口号>
```
修改完ip或端口号后，终端将会输出如下信息
![启动dstackspy](https://raw.githubusercontent.com/whqfor/sources/master/blog/spy/copy地址.png)
打开web页地址，然后将ip和端口号一起copy到工程中，这是为了和工程监理scoket通信。
   
3. 工程集成
pubspec.yaml 中添加 
```
d_spy: ^0.X.X
```
在初始化DStack的时候添加`nodeObserver:`
```
DStack.instance.register(
  builders: RouterBuilder.builders(),
  nodeObserver: DSpyNodeObserver('10.75.44.5:9023'));
```
DSpyNodeObserver中的参数即是终端中输出的`ip和端口号`

Android侧需要在混合栈DStack初始化的时候将节点打开，iOS不需要设置
```java
DStack.getInstance().setOpenNodeOperation(true)
```
到此可视化插件集成完成，当用户启动APP时，前端页面即可实时的展示用户的页面对应节点信息。

[DStack混合栈可视化插件d_spy配置及演示视频](https://www.bilibili.com/video/BV1Rz4y1U7iH)

效果展示：
![spy_web.png](https://raw.githubusercontent.com/whqfor/sources/master/blog/spy/spy_web.png)

#### 补充
 有一点需要说明的是，DSpyNodeObserver还有一个可选参数`milliseconds`，这个参数是为了截屏设置的，截屏操作只会在页面`push`、`present`时截取，考虑到APP中绝大部分页面是需要网络请求或其他操作后才能显示，并且网络数据是异步的。Spy插件如果监听到页面打开后立刻进行截屏的话，大概率是一个空白页面，这样可视化效果就不太理想。因此暴露此参数给用户自行设置，默认是1000毫秒时间，用户自行预估平均页面展示需要花费多长时间，进行设置即可。
 
#### 展望
可视化插件Spy的设计初衷，除了为了方便用户解决混合栈节点信息排查，也是一次混合栈DStack设计思想（基于节点的混合栈管理）的应用，DStack在初始化时暴露了nodeObserve给用户，nodeObserve会将APP的所有页面操作，及其产生的节点信息暴露给开发者。可视化插件Spy即是基于此实现，也算是给使用DStack的开发者做了一次示例。

类似于可视化插件Spy，如果将nodeObserve回调的所有节点信息上传到后端，或者保存一份到本地，那么之后可以根据存储下来的信息，进行用户行为分析，场景回放，以更好的服务于用户。

由于开发时间有限，可视化插件在视觉上还有需要优化改进的地方，期待和大家一起交流。
