// 多端断点系统
// sm: 手机竖屏 (<600vp)
// md: 平板竖屏/手机横屏 (600-840vp)
// lg: 平板横屏/2in1 (>840vp)
export enum BreakpointType {
    SM = "sm",
    MD = "md",
    LG = "lg"
}
export class BreakpointSystem {
    private currentBreakpoint: BreakpointType = BreakpointType.SM;
    // 根据宽度获取断点类型
    getBreakpoint(width: number): BreakpointType {
        if (width >= 840) {
            return BreakpointType.LG;
        }
        else if (width >= 600) {
            return BreakpointType.MD;
        }
        else {
            return BreakpointType.SM;
        }
    }
    // 更新断点
    updateBreakpoint(width: number): BreakpointType {
        this.currentBreakpoint = this.getBreakpoint(width);
        return this.currentBreakpoint;
    }
    // 获取当前断点
    getCurrentBreakpoint(): BreakpointType {
        return this.currentBreakpoint;
    }
    // 获取内容区最大宽度
    getContentMaxWidth(): Length {
        switch (this.currentBreakpoint) {
            case BreakpointType.LG:
                return 1200;
            case BreakpointType.MD:
                return 800;
            case BreakpointType.SM:
            default:
                return '100%';
        }
    }
    // 是否显示侧边栏布局
    isSideBarMode(): boolean {
        return this.currentBreakpoint === BreakpointType.LG;
    }
}
export const breakpointSystem = new BreakpointSystem();
