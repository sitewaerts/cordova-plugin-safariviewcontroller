interface SafariViewController {
    isAvailable(success: (available: boolean) => void): void

    show(options: SafariViewControllerShowOptions, onMessage: (message: SafariViewControllerShowMessage) => void, error: (error: any) => void): void

    hide(success: () => void, error: (error: any) => void): void


    /**
     * android only
     */
    connectToService(success: () => void, error: (error: any) => void): void

    /**
     * android only
     */
    warmUp(success: () => void, error: (error: any) => void): void

    /**
     * android only
     */
    getViewHandlerPackages(success: (packages: { defaultHandler: string, customTabsImplementations: Array<string> }) => void, error: (error: any) => void): void

    /**
     * android only
     */
    useCustomTabsImplementation(packageName: string, success: () => void, error: (error: any) => void): void

    /**
     * android only
     */
    useChrome(success: () => void, error: (error: any) => void): void

    /**
     * android only
     */
    mayLaunchUrl(url: string, success: () => void, error: (error: any) => void): void

}

interface SafariViewControllerShowMessage {
    event: 'opened' | 'loaded' | 'closed'
}

interface SafariViewControllerShowOptions {
    url: string,
    hidden?: boolean, // default false. You can use this to load cookies etc. in the background (see issue #1 for details).
    animated?: boolean, // default true, note that 'hide' will reuse this preference (the 'Done' button will always animate though)
    enterReaderModeIfAvailable?: boolean, // default false
    tintColor?: string, // default is ios blue
    barColor?: string, // on iOS 10+ you can change the background color as well
    controlTintColor?: string, // on iOS 10+ you can override the default tintColor
    toolbarColor?: string, // Android
    showDefaultShareMenuItem?: boolean
}

interface Window {
    // available as window.SafariViewController
    SafariViewController: SafariViewController
}
