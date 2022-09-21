# RT-Thread AT (EC200x)


## **RT-Thread 设备模型**

![Untitled](assets/RT-Thread%20AT%20(EC200x)/Untitled.png)

- 简单设备，不经过**设备驱动框架层**
    1. 设备驱动根据设备模型定义，创建出具备硬件访问能力的设备实例，将该设备通过 `rt_device_register()` 接口注册到 I/O 设备管理器中。
    2. 应用程序通过 `rt_device_find()` 接口查找到设备，然后使用 I/O 设备管理接口来访问硬件。
- 其它设备，经过**设备驱动框架层**，例如看门狗
    1. 看门狗设备驱动程序根据看门狗设备模型定义，创建出具备硬件访问能力的看门狗设备实例，并将该看门狗设备通过 `rt_hw_watchdog_register()` 接口注册到**看门狗设备驱动**框架中。
    2. **看门狗设备驱动框架**通过 `rt_device_register()` 接口将看门狗设备注册到 I/O 设备管理器中。
    3. 应用程序通过 I/O 设备管理接口来访问看门狗设备硬件。

也就是说，**其它设备**比**简单设备**多了一层（或多层）设备驱动框架，设备驱动框架定义统一接口，使得各类硬件芯片虽然实现方式不一样，但是在应用层使用时不会感知到这些差异。

**EC200x 属于复杂设备，EC200x 类属于 AT 设备类的子类。**

## 相关数据结构定义

EC200x 主要相关数据结构如下图所示：

![Untitled](assets/RT-Thread%20AT%20(EC200x)/Untitled%201.png)

### **AT 设备类数据结构**

AT 设备类 `struct at_device_class` 规定了**设备 ID 域、AT 设备操作接口类、Socket 数量域、Socket 操作接口类、设备链表域（用于将同类设备连接到链表）**。数据结构：

```c
 struct at_device_class
 {
     uint16_t class_id;                           /* AT device class ID */
     const struct at_device_ops *device_ops;      /* AT device operaiotns */
 #ifdef AT_USING_SOCKET
     uint32_t socket_num;                         /* The maximum number of sockets support */
     const struct at_socket_ops *socket_ops;      /* AT device socket operations */
 #endif
     rt_slist_t list;                             /* AT device class list */
 };
```

- AT 设备操作类
    
    包含的方法有：**初始化、去初始化、操作控制**。
    
    ```c
     /* AT device operations */
     struct at_device_ops
     {
         int (*init)(struct at_device *device);
         int (*deinit)(struct at_device *device);
         int (*control)(struct at_device *device, int cmd, void *arg);
     };
    ```
    
- Socket 操作类
    
    包含的方法有：**创建 Socket、关闭 Socket、连接、发送、事件回调函数注册、域名解析**。
    
    ```c
    /* AT socket operations function */
    struct at_socket_ops
    {
        int (*at_connect)(struct at_socket *socket, char *ip, int32_t port, enum at_socket_type type, rt_bool_t is_client);
        int (*at_closesocket)(struct at_socket *socket);
        int (*at_send)(struct at_socket *socket, const char *buff, size_t bfsz, enum at_socket_type type);
        int (*at_domain_resolve)(const char *name, char ip[16]);
        void (*at_set_event_cb)(at_socket_evt_t event, at_evt_cb_t cb);
        int (*at_socket)(struct at_device *device, enum at_socket_type type);
    };
    ```
    

### AT Client 数据结构

`struct at_client` 定义了 AT Client 使用的 **device（UART）、接收缓冲区大小、AT 命令响应数据结构、URC 处理函数表**等内容。

```c
struct at_client
{
    rt_device_t device;

    at_status_t status;
    char end_sign;

    /* the current received one line data buffer */
    char *recv_line_buf;
    /* The length of the currently received one line data */
    rt_size_t recv_line_len;
    /* The maximum supported receive data length */
    rt_size_t recv_bufsz;
    rt_sem_t rx_notice;
    rt_mutex_t lock;

    at_response_t resp;
    rt_sem_t resp_notice;
    at_resp_status_t resp_status;

    struct at_urc_table *urc_table;
    rt_size_t urc_table_size;

    rt_thread_t parser;
};
```

### 网络设备数据结构

`struct netdev` 定义了 **IP 地址、子网掩码、DNS 服务器、硬件地址、状态改变时回调、地址改变时回调**等内容。其中还定义了 `const struct netdev_ops *ops;` **网络操作数据结构**。

```c
/* network interface device object */
struct netdev
{
    rt_slist_t list; 
    
    char name[RT_NAME_MAX];                            /* network interface device name */
    ip_addr_t ip_addr;                                 /* IP address */
    ip_addr_t netmask;                                 /* subnet mask */
    ip_addr_t gw;                                      /* gateway */
#if NETDEV_IPV6
    ip_addr_t ip6_addr[NETDEV_IPV6_NUM_ADDRESSES];     /* array of IPv6 addresses */
#endif /* NETDEV_IPV6 */
    ip_addr_t dns_servers[NETDEV_DNS_SERVERS_NUM];     /* DNS server */
    uint8_t hwaddr_len;                                /* hardware address length */
    uint8_t hwaddr[NETDEV_HWADDR_MAX_LEN];             /* hardware address */
    
    uint16_t flags;                                    /* network interface device status flag */
    uint16_t mtu;                                      /* maximum transfer unit (in bytes) */
    const struct netdev_ops *ops;                      /* network interface device operations */
    
    netdev_callback_fn status_callback;                /* network interface device flags change callback */
    netdev_callback_fn addr_callback;                  /* network interface device address information change callback */

#ifdef RT_USING_SAL
    void *sal_user_data;                               /* user-specific data for SAL */
#endif /* RT_USING_SAL */
    void *user_data;                                   /* user-specific data */
};
```

`const struct netdev_ops *ops;` 定义了**启用网络设备、禁用网络设备、设置 IP 地址**等操作接口。

```c
/* The network interface device operations */
struct netdev_ops
{
    /* set network interface device hardware status operations */
    int (*set_up)(struct netdev *netdev);
    int (*set_down)(struct netdev *netdev);

    /* set network interface device address information operations */
    int (*set_addr_info)(struct netdev *netdev, ip_addr_t *ip_addr, ip_addr_t *netmask, ip_addr_t *gw);
    int (*set_dns_server)(struct netdev *netdev, uint8_t dns_num, ip_addr_t *dns_server);
    int (*set_dhcp)(struct netdev *netdev, rt_bool_t is_enabled);

#ifdef RT_USING_FINSH
    /* set network interface device common network interface device operations */
    int (*ping)(struct netdev *netdev, const char *host, size_t data_len, uint32_t timeout, struct netdev_ping_resp *ping_resp);
    void (*netstat)(struct netdev *netdev);
#endif

    /* set default network interface device in current network stack*/
    int (*set_default)(struct netdev *netdev);
};
```

### AT Socket 数据结构

`struct at_socket` 定义 **Socket 类型、收发超时、收发计数**等内容。

```c
struct at_socket
{
    /* AT socket magic word */
    uint32_t magic;

    int socket;
    /* device releated information for the socket */
    void *device;
    /* type of the AT socket (TCP, UDP or RAW) */
    enum at_socket_type type;
    /* current state of the AT socket */
    enum at_socket_state state;
    /* sockets operations */
    const struct at_socket_ops *ops;
    /* receive semaphore, received data release semaphore */
    rt_sem_t recv_notice;
    rt_mutex_t recv_lock;
    rt_slist_t recvpkt_list;

    /* timeout to wait for send or received data in milliseconds */
    int32_t recv_timeout;
    int32_t send_timeout;
    /* A callback function that is informed about events for this AT socket */
    at_socket_callback callback;

    /* number of times data was received, set by event_callback() */
    uint16_t rcvevent;
    /* number of times data was ACKed (free send buffer), set by event_callback() */
    uint16_t sendevent;
    /* error happened for this socket, set by event_callback() */
    uint16_t errevent;

#ifdef SAL_USING_POSIX
    rt_wqueue_t wait_head;
#endif
    rt_slist_t list;

    /* user-specific data */
    void *user_data;
};
```

### User data

使得子成员能过通过指针获取父结构体变量，例如 `at_device_ec200x _dev` 的成员 `at_device device` 的 `user data` 指向**父结构体**：

```c
static struct at_device_ec200x _dev =
{
    EC200X_SAMPLE_DEIVCE_NAME,
    EC200X_SAMPLE_CLIENT_NAME,

    EC200X_SAMPLE_POWER_PIN,
    EC200X_SAMPLE_STATUS_PIN,
    EC200X_SAMPLE_WAKEUP_PIN,
    EC200X_SAMPLE_RECV_BUFF_LEN,
};
struct at_device_ec200x *ec200x = &_dev;
&(ec200x->device)->user_data = (void *) ec200x;
```

## EC200x **设备类注册**

EC200x 类设备属于 **AT 设备类**，需要实现 **AT 设备类**中定义的 **AT 设备的操作接口**和 **Socket 设备操作接口**。EC200x 类的注册流程为：

- AT 设备类接口实现
    1. 申请 AT 设备类所需的动态空间：
        
        ```c
        struct at_device_class *class = RT_NULL;
        class = (struct at_device_class *) rt_calloc(1, sizeof(struct at_device_class));
        ```
        
    2. 实现 Socket 设备接口：
        
        ```c
        ec200x_socket_class_register(class);
        ```
        
        `ec200x_socket_class_register()` 实现了**连接、关闭、发送、域名解析、事件回调**方法，这些方法会在 `at_socket_ops()` 中调用。
        
        ```c
        int ec200x_socket_class_register(struct at_device_class *class)
        {
            RT_ASSERT(class);
        
            class->socket_num = AT_DEVICE_EC200X_SOCKETS_NUM;
            class->socket_ops = &ec200x_socket_ops;
        
            return RT_EOK;
        }
        
        static const struct at_socket_ops ec200x_socket_ops =
        {
            ec200x_socket_connect,
            ec200x_socket_close,
            ec200x_socket_send,
            ec200x_domain_resolve,
            ec200x_socket_set_event_cb,
        #if defined(AT_SW_VERSION_NUM) && AT_SW_VERSION_NUM > 0x10300
            RT_NULL,
        #endif
        };
        ```
        
    3. 实现 AT 设备类的设备接口，包括 EC200x 类的**初始化、去初始化、控制**方法：
        
        ```c
        const struct at_device_ops ec200x_device_ops =
        {
            ec200x_init,
            ec200x_deinit,
            ec200x_control,
        };
        
        class->device_ops = &ec200x_device_ops;
        ```
        
- 注册 AT 设备类
    
    AT 设备类注册在 `ec200x_device_class_register` 中进行，此方法使用 `INIT_DEVICE_EXPORT(ec200x_device_class_register);` 标记，因此会**在设备初始化阶段自动调用**。
    
    ```c
    #define AT_DEVICE_CLASS_EC200X         0x10U
    
    static int ec200x_device_class_register(void)
    {
    		...
        return at_device_class_register(class, AT_DEVICE_CLASS_EC200X);
    }
    INIT_DEVICE_EXPORT(ec200x_device_class_register);
    
    int at_device_class_register(struct at_device_class *class, uint16_t class_id)
    {
        rt_base_t level;
    
        RT_ASSERT(class);
    
        /* Fill AT device class */
        class->class_id = class_id;
    
        /* Initialize current AT device class single list */
        rt_slist_init(&(class->list));
    
        level = rt_hw_interrupt_disable();
    
        /* Add current AT device class to list */
        rt_slist_append(&at_device_class_list, &(class->list));
    
        rt_hw_interrupt_enable(level);
    
        return RT_EOK;
    }
    ```
    

## **EC200x 初始化流程**

- 设备配置
    
    配置 EC200x 用户数据结构：
    
    ```c
    struct at_device_ec200x
    {
        char *device_name;
        char *client_name;
    
        int power_pin;
        int power_status_pin;
        int wakeup_pin;
        size_t recv_line_num;
        struct at_device device;
    
        void *socket_data;
        void *user_data;
    
        rt_bool_t power_status;
        rt_bool_t sleep_status;
    };
    
    #define EC200X_SAMPLE_DEIVCE_NAME "ec200x"
    #define EC200X_SAMPLE_CLIENT_NAME "uart2"
    #define EC200X_SAMPLE_POWER_PIN -1
    #define EC200X_SAMPLE_STATUS_PIN -1
    #define EC200X_SAMPLE_WAKEUP_PIN -1
    #define EC200X_SAMPLE_RECV_BUFF_LEN 512
    
    static struct at_device_ec200x _dev =
    {
        EC200X_SAMPLE_DEIVCE_NAME,
        EC200X_SAMPLE_CLIENT_NAME,
    
        EC200X_SAMPLE_POWER_PIN,
        EC200X_SAMPLE_STATUS_PIN,
        EC200X_SAMPLE_WAKEUP_PIN,
        EC200X_SAMPLE_RECV_BUFF_LEN, 
    };
    ```
    
- 设备注册
    1. 注册 EC200x 设备实例对象，使用 `INIT_APP_EXPORT` 实现**自动调用**，需要注意其中的 `(void *)ec200x` 参数，后续操作中经常通过 AT 设备指针 `device->user_data` 访问 ec200x 设备：
        
        ```c
        static int ec200x_device_register(void)
        {
            struct at_device_ec200x *ec200x = &_dev;
        
            return at_device_register(&(ec200x->device),
                                      ec200x->device_name,
                                      ec200x->client_name,
                                      AT_DEVICE_CLASS_EC200X,
                                      (void *) ec200x);
        }
        INIT_APP_EXPORT(ec200x_device_register);
        ```
        
    2. 通过配置的 `class_id`（0x10U）获取设备类，即上述通过 `INIT_DEVICE_EXPORT(ec200x_device_class_register);` 注册的 `at_device_class`。
        
        ```c
        class = at_device_class_get(class_id);
        ```
        
    3. 申请 Socket 空间，创建 Socket 事件集：
        
        ```c
        device->sockets = (struct at_socket *) rt_calloc(class->socket_num, sizeof(struct at_socket));
        device->socket_event = rt_event_create(name, RT_IPC_FLAG_FIFO);
        ```
        
    4. 设置设备名、设备类、user_data：
        
        ```c
        // #define EC200X_SAMPLE_DEIVCE_NAME "ec200x”
        rt_memcpy(device->name, device_name, rt_strlen(device_name));
        
        // class: at_device_class
        device->class = class;
        
        // user_data: struct at_device_ec200x _dev
        device->user_data = user_data;
        ```
        
    5. 将 EC200x 设备实例添加到 AT 设备链表：
        
        ```c
        rt_slist_init(&(device->list));
        
        level = rt_hw_interrupt_disable();
        rt_slist_append(&at_device_list, &(device->list));
        rt_hw_interrupt_enable(level);
        ```
        
    6. 调用 EC200x 设备初始化：`class->device_ops->init(device);`
- 设备初始化
    
    调用 `at_device_register` 注册 AT 设备时，会调用此实例的 `class->device_ops->init` 方法（即 `ec200x_init`），并且从此开始初始化 EC200x 设备，注册成功后可以就可以使用 EC200x 设备。
    
    ```c
    int at_device_register(struct at_device *device, const char *device_name,
                            const char *at_client_name, uint16_t class_id, void *user_data)
    {
    		...
    		/* Initialize AT device */
    		result = class->device_ops->init(device);
    		...
    }
    ```
    
    `ec200x_init(struct at_device *device)` 完成以下工作：
    
    1. 通过 AT 设备指针获取 EC200x 实例：
        
        ```c
        ec200x = (struct at_device_ec200x *) device->user_data;
        ```
        
    2. 初始化 AT Client 和串口：
        
        ```c
        at_client_init(ec200x->client_name, ec200x->recv_line_num);
        ```
        
    3. Socket 初始化，主要是指定相关 URC 处理函数：
        
        ```c
        ec200x_socket_init(device);
        ```
        
    4. 实例化网络设备：
        
        ```c
        device->netdev = ec200x_netdev_add(ec200x->device_name);
        ```
        
        ```c
        static struct netdev *ec200x_netdev_add(const char *netdev_name)
        {
        	netdev = (struct netdev *)rt_calloc(1, sizeof(struct netdev));
            netdev->mtu = ETHERNET_MTU;
            netdev->ops = &ec200x_netdev_ops;
            netdev->hwaddr_len = HWADDR_LEN;
        
            /* set the network interface socket/netdb operations */
            sal_at_netdev_set_pf_info(netdev);
        
            netdev_register(netdev, netdev_name, RT_NULL);
        }
        ```
        
        实例化调用了 `sal_at_netdev_set_pf_info()` 函数，用于配置 SAL 协议簇。在这里，netdev_name 和 EC200x 的设备名一致，都是 `“ec200”`。执行此步骤之后就可以使用 `netdev_get_by_name()` 查找并使用设备了。
        
    5. 电源相关引脚初始化:
        
        ```c
        if (ec200x->power_pin != -1)
        {
            rt_pin_write(ec200x->power_pin, PIN_LOW);
            rt_pin_mode(ec200x->power_pin, PIN_MODE_OUTPUT);
        }
        if (ec200x->power_status_pin != -1)
        {
            rt_pin_mode(ec200x->power_status_pin, PIN_MODE_INPUT);
        }
        if (ec200x->wakeup_pin != -1)
        {
            rt_pin_write(ec200x->wakeup_pin, PIN_LOW);
            rt_pin_mode(ec200x->wakeup_pin, PIN_MODE_OUTPUT);
        }
        ```
        
    6. 启动网络设备：
        
        ```c
        ec200x_netdev_set_up(device->netdev)
        ```
        
        ```c
        // 获取 AT 设备实例
        device = at_device_get_by_name(AT_DEVICE_NAMETYPE_NETDEV, netdev->name);
        
        if (device->is_init == RT_FALSE)
        {
        		// 创建 ec200x_init_thread_entry 线程，用于执行初始化 AT 命令序列
        		// 包括 AT 连接、SIM 连接、波特率配置、网络注册等
            ec200x_net_init(device);
            device->is_init = RT_TRUE;
        
        		// 设置网络设备状态变量
            netdev_low_level_set_status(netdev, RT_TRUE);
            LOG_D("network interface device(%s) set up status.", netdev->name);
        }
        ```
        
        在 `ec200x_net_init` 中，还执行了以下代码：
        
        ```c
        ec200x_netdev_set_info(device->netdev);
        /* check and create link staus sync thread  */
        if (rt_thread_find(device->netdev->name) == RT_NULL)
        {
            ec200x_netdev_check_link_status(device->netdev);
        }
        ```
        
        `ec200x_netdev_check_link_status` 创建了 `ec200x_check_link_status_entry` 线程，用于在系统运行时检测网络状态（`AT+CGREG?`）。