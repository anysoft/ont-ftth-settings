# ont-ftth-settings
ONT (Optical Network Terminal) / Fiber to the Home (FTTH) modem network VLAN configuration.

[toc]

# 基础说明
	目前认证方式分为 LOID 账号密码、PASSWORD 密码验证、光猫 SN 序列号、光猫 MAC 物理地址等，运营商会选取一种或者几种组合验证。光猫 SN 序列号和 MAC 地址在会标在光猫底部，LOID 账号密码需要从运营商客服 / 宽带安装师傅那获取，同时也需要宽带拨号 / 电话 / IPTV 对应的 Vlan 值。每个城市或者省份的同一运营商，默认采用同一套认证方式，各区域 Vlan 通常也是一致的，可以通过分享的方法简化操作，大家可以在评论区留言分享，本文会实时更新数据。 

TR069 基本是远程管理，封装类型

## 字段解释(2_INTERNET_R_VID_41)
- 2	连接序号，不同用户可能不一样
- INTERNET	表示是上网业务。TR069 表示管理
- R	Route，B Bridge 光猫拨号的路由模式
- VID	VLAN ID 的简写
- 41	不同用户一般不一样，涉及到交换机 VLAN 配置



## 中国电信

### TR09 配置



### 天津
| 类别 |   全称   |   vlanId/mru/mtu   |封装类型|
| ---- | ---- | ---- | ---- |
|  TR069    | 1_TR069_VOICE_R_VID_ |  | IPoE|
|  INTERNET    | 2_Other_B_VID_105 | 105 |PPPoE|
|  OTHER    | 3_INTERNET_R_VID_46  | 46 |Bridge|
|  IPTV    | 3_IPTV_B_VID_3003 | 3003 |IPoE|
认证方式：LOID

### 广东
#### 深圳
| 类别 |   全称   |   vlanId/mru/mtu   |封装类型|
| ---- | ---- | ---- | ---- |
|  TR069    | 1_TR069_VOICE_R_VID_46 | 46 | IPoE|
|  INTERNET    | 2_Other_B_VID_45 | 45 |PPPoE|
|  OTHER    | 3_INTERNET_R_VID_41  | 41 |Bridge|



### 浙江

#### 温州

| 类别                              | 全称                   | vlanId/mru/mtu/802.1p | 封装类型 |
| --------------------------------- | ---------------------- | --------------------- | -------- |
| TR069                             | 1_TR069_VOICE_R_VID_46 | 46//1492/7            | IPoE     |
| INTERNET                          | 2_INTERNET_R_VID_41    | 41/1492/1             | PPPoE    |
| 认证方式：Password 码认证下发业务 | 3_Other_B_VID_43       | 43//1500/4            | PPPoE    |





## 中国移动

### 浙江
#### 温州
| 类别 |   全称   |   vlanId/mru/mtu   |封装类型|
| ---- | ---- | ---- | ---- |
|  TR069    | 1_TR069_VOICE_R_VID_4034 | 4034 | IPoE|
|  INTERNET    | 2_Other_B_VID_4031 | 4031 |PPPoE|
认证方式：Password 码认证下发业务





### 广东

#### 深圳
| 类别 |   全称   |   vlanId/mru/mtu   |封装类型|
| ---- | ---- | ---- | ---- |
|  TR069    | 1_TR069_R_VID_46 | 46 | IPoE|
|  INTERNET    | 2_INTERNET_R_VID_41 | 41 |PPPoE|
|  OTHER    | 3_OTHER_B_VID_43  | 43 |Bridge|
|  VOIP    | 4_VOIP_R_VID_45 | 45 |DHCP|
认证方式：Password 码认证下发业务

### 辽林
| 类别 |   全称   |   vlanId/mru/mtu   |封装类型|
| ---- | ---- | ---- | ---- |
|  TR069    | 1_TR069_R_VID_4011 | 4011 |IPoE|
|  INTERNET    | 2_INTERNET_R_VID_1340 | 1340 |PPPoE|
|  IPTV    | 3_IPTV_B_VID_4017 | 4017 |IPoE|
认证方式：LOID&密码+SN认证



## 中国联通

## TR69 配置

http://rms.chinaunicom.cn:9090/RMS-server/RMS
cpe/cpe
rms/rms

http://devacs.edatahome.com:9090/ACS-server/ACS

hgw/hgw

itms/itms

### 北京
| 类别 |   全称   |   vlanId/mru/mtu   |封装类型|
| ---- | ---- | ---- | ---- |
|  TR069    | 1_TR069_R_VID_ |  |IPoE|
|  INTERNET    | 2_INTERNET_R_VID_3961 |  |PPPoE|
|  OTHER    | 3_IPTV_B_VID_3962 | 3962 |IPoE|
|  IPTV    | 3_IPTV_B_VID_3964 | 3964 |IPoE|
认证方式：MAC
### 辽林
| 类别 |   全称   |   vlanId/mru/mtu   |封装类型|
| ---- | ---- | ---- | ---- |
|  TR069    | 1_TR069_R_VID_ |  |IPoE|
|  INTERNET    | 2_INTERNET_R_VID_2001 | 2001 |PPPoE|
认证方式：LOID

### 广东
#### 深圳
| 类别 |   全称   |   vlanId/mru/mtu   |封装类型|
| ---- | ---- | ---- | ---- |
|  TR069    | 1_TR069_R_VID_ | 46/802.1p=6/1500 |IPoE|
|  INTERNET    | 2_INTERNET_R_VID_ | vid=41/802.1p=0 |PPPoE|
|  IPTV    | 2_IPTV_B_VID_ | vid=45/45/802.1p=4 |PPPoE|
|认证方式：LOID||||





## 天威视讯

## TR69配置

周期通知时间间隔：43200

ACS URL：http://acs.topway.cn:9090/acs

ACS用户名：Acs

ACS密码：Acs
请求连接的用户名：Cpe
请求连接的密码：Cpe
DSCP：0



### 广东
#### 深圳
| 类别 |   全称   |   vlanId/mru/mtu   |封装类型|
| ---- | ---- | ---- | ---- |
|  TR069    | 1_TR069_R_VID_540 | 540//1500 |IPoE|
|  INTERNET    | 2_INTERNET_R_VID_10 | 10/1492 |PPPoE|
|  IPTV    | 3_IPTV_B_VID_98 | 98 |IPoE|
认证方式：SN





IPV6 配置

- 前缀获取方式：PrefixDelegation
- IP获取方式：AutoConfigured
- IP地址状态：无状态	



# 参考来源
- http://www.myzaker.com/article/601431a88e9f0966447d856a
- https://v2ex.com/t/628238
- https://www.bilibili.com/read/cv15511350
- 