import type { IStockLocationService } from '@medusajs/framework/types'
import type { IInventoryService } from '@medusajs/framework/types'
import type { IProductModuleService } from '@medusajs/framework/types'
import type { IPricingModuleService } from '@medusajs/framework/types'
import type { IPromotionModuleService } from '@medusajs/framework/types'
import type { ICustomerModuleService } from '@medusajs/framework/types'
import type { ISalesChannelModuleService } from '@medusajs/framework/types'
import type { ICartModuleService } from '@medusajs/framework/types'
import type { IRegionModuleService } from '@medusajs/framework/types'
import type { IApiKeyModuleService } from '@medusajs/framework/types'
import type { IStoreModuleService } from '@medusajs/framework/types'
import type { ITaxModuleService } from '@medusajs/framework/types'
import type { ICurrencyModuleService } from '@medusajs/framework/types'
import type { IPaymentModuleService } from '@medusajs/framework/types'
import type { IOrderModuleService } from '@medusajs/framework/types'
import type { ISettingsModuleService } from '@medusajs/framework/types'
import type { IAuthModuleService } from '@medusajs/framework/types'
import type { IUserModuleService } from '@medusajs/framework/types'
import type { IFulfillmentModuleService } from '@medusajs/framework/types'
import type { INotificationModuleService } from '@medusajs/framework/types'
import type { ICacheService } from '@medusajs/framework/types'
import type { IEventBusModuleService } from '@medusajs/framework/types'
import type { IWorkflowEngineService } from '@medusajs/framework/types'
import type { ILockingModule } from '@medusajs/framework/types'
import type { IFileModuleService } from '@medusajs/framework/types'
import type Marketplace from '../../src/modules/marketplace'
import type Chat from '../../src/modules/chat'
import type NotificationCenter from '../../src/modules/notification-center'
import type PaymentMethodsModule from '../../src/modules/payment-methods'
import type ShortVideo from '../../src/modules/short-video'
import type SocketModule from '../../src/modules/socket'
import type OpeninaryImageModule from '../../src/modules/openinary-image'
import type Review from '../../src/modules/review'

declare module '@medusajs/framework/types' {
  interface ModuleImplementations {
    'stock_location': IStockLocationService,
    'inventory': IInventoryService,
    'product': IProductModuleService,
    'pricing': IPricingModuleService,
    'promotion': IPromotionModuleService,
    'customer': ICustomerModuleService,
    'sales_channel': ISalesChannelModuleService,
    'cart': ICartModuleService,
    'region': IRegionModuleService,
    'api_key': IApiKeyModuleService,
    'store': IStoreModuleService,
    'tax': ITaxModuleService,
    'currency': ICurrencyModuleService,
    'payment': IPaymentModuleService,
    'order': IOrderModuleService,
    'settings': ISettingsModuleService,
    'auth': IAuthModuleService,
    'user': IUserModuleService,
    'fulfillment': IFulfillmentModuleService,
    'notification': INotificationModuleService,
    'cache': ICacheService,
    'event_bus': IEventBusModuleService,
    'workflows': IWorkflowEngineService,
    'locking': ILockingModule,
    'file': IFileModuleService,
    'marketplace': InstanceType<(typeof Marketplace)['service']>,
    'chat': InstanceType<(typeof Chat)['service']>,
    'notificationCenter': InstanceType<(typeof NotificationCenter)['service']>,
    'paymentMethodsModule': InstanceType<(typeof PaymentMethodsModule)['service']>,
    'short_video': InstanceType<(typeof ShortVideo)['service']>,
    'socketModule': InstanceType<(typeof SocketModule)['service']>,
    'openinaryImageModule': InstanceType<(typeof OpeninaryImageModule)['service']>,
    'review': InstanceType<(typeof Review)['service']>
  }
}