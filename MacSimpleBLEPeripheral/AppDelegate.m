//
//  AppDelegate.m
//  MacSimpleBLEPeripheral
//
//  Created by takanori uehara on 2014/11/15.
//  Copyright (c) 2014年 takanori uehara. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate() {
    NSStatusItem *statusItem;
    NSMenu *statusItemMenu;
    
    PeripheralController *peripheralController;
}

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    // ペリフェラルコントローラ生成
    peripheralController = [[PeripheralController alloc] initPeripheral];
    
    // ステータスバー表示設定
    statusItemMenu = [[NSMenu alloc] init];
    //    [statusItemMenu removeAllItems];
    [statusItemMenu setAutoenablesItems:NO];
    NSMenuItem *startItem = [statusItemMenu addItemWithTitle:@"Start" action:@selector(startAdvertising:) keyEquivalent:@"r"];
    [startItem setKeyEquivalentModifierMask:NSCommandKeyMask];
    [startItem setEnabled:YES];
    NSMenuItem *stopItem = [statusItemMenu addItemWithTitle:@"Stop" action:@selector(stopAdvertising:) keyEquivalent:@"."];
    [stopItem setKeyEquivalentModifierMask:NSCommandKeyMask];
    [stopItem setEnabled:NO];
    NSMenuItem *updateValueItem = [statusItemMenu addItemWithTitle:@"Update value" action:@selector(updateValue:) keyEquivalent:@"u"];
    [updateValueItem setKeyEquivalentModifierMask:NSCommandKeyMask];
    [updateValueItem setEnabled:YES];
    [statusItemMenu addItem:[NSMenuItem separatorItem]];
    NSMenuItem *quitItem = [statusItemMenu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
    [quitItem setKeyEquivalentModifierMask:NSCommandKeyMask];
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setImage:[NSImage imageNamed:@"statusbar_icon"]];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:statusItemMenu];
}

- (NSMenuItem*)getMenuItem:(NSMenu*)menu index:(NSInteger)index {
    NSMenuItem *menuItem = [NSMenuItem new];
    NSArray *items = [statusItemMenu itemArray];
    if ([items count] > index) menuItem = [[statusItemMenu itemArray] objectAtIndex:index];
    return menuItem;
}

- (void)startAdvertising:(id)sender {
    [peripheralController startAdvertising];
    [(NSMenuItem*)sender setEnabled:NO];
    [[self getMenuItem:statusItemMenu index:1] setEnabled:YES];
}

- (void)stopAdvertising:(id)sender {
    [peripheralController stopAdvertising];
    [(NSMenuItem*)sender setEnabled:NO];
    [[self getMenuItem:statusItemMenu index:0] setEnabled:YES];
}

- (void)updateValue:(id)sender {
    [peripheralController updatePeripheralValue:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)hoge:(id)sender {
}
@end
