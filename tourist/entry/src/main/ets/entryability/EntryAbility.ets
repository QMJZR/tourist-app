import { abilityAccessCtrl, AbilityConstant, ConfigurationConstant,
  Permissions,
  UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { geoLocationManager } from '@kit.LocationKit';
import { BusinessError } from '@kit.BasicServicesKit';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/MainPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');

      this.requestLocationPermission();
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }


  // [+] 新增：申请位置权限并获取位置
  private requestLocationPermission(): void {
    try {
      const atManager = abilityAccessCtrl.createAtManager();

      // [+] 方法1：直接内联传递，让TypeScript推断
      atManager.requestPermissionsFromUser(
        this.context,
        ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION']
      ).then((data) => {
        // [+] data 的类型应该由API定义，直接使用
        if (data.authResults && data.authResults[0] === 0) {
          hilog.info(DOMAIN, 'testTag', '位置权限已授权');
          this.getCurrentLocation();
        } else if (data.authResults) {
          hilog.warn(DOMAIN, 'testTag', '位置权限被拒绝，状态码: %{public}d', data.authResults[0]);
        }
      }).catch((err: Error) => {
        hilog.error(DOMAIN, 'testTag', '权限申请失败: %{public}s', err.message);
      });

    } catch (err) {
      const error = err as Error;
      hilog.error(DOMAIN, 'testTag', '权限申请异常: %{public}s', error.message);
    }
  }
  // [+] 新增：获取当前位置（最简化）
  private async getCurrentLocation(): Promise<void> {
    try {
      const location = await geoLocationManager.getCurrentLocation();
      hilog.info(
        DOMAIN,
        'testTag',
        '位置获取成功: 经度=%{public}f, 纬度=%{public}f',
        location.longitude,
        location.latitude
      );
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', '获取位置失败: %{public}s', JSON.stringify(err));
    }
  }
}