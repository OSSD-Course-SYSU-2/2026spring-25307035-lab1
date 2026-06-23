import hilog from '@ohos.hilog';

export default function abilityTest() {
  hilog.info(0x0000, 'testTag', '%{public}s', 'ability test called');
}
