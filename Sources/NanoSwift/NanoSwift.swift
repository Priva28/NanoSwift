public class Nano {
    public let accounts: NanoAccountManager
    public let wallets: NanoWalletManager
    public let blocks: NanoBlockManager
    public func newNode(address: String) -> NanoNode { NanoNode(address: address) }
    public init() {
        let accountFunctions = NanoAccountFunctions()
        let walletFunctions = NanoWalletFunctions()
        let blockFunctions = NanoBlockFunctions(accountFunctions: accountFunctions)
        
        let accounts = NanoAccountManager(accountFunctions: accountFunctions)
        let wallets = NanoWalletManager(walletFunctions: walletFunctions, accountManager: accounts)
        let blocks = NanoBlockManager(blockFunctions: blockFunctions, accountFunctions: accountFunctions)
        
        self.accounts = accounts
        self.wallets = wallets
        self.blocks = blocks
    }
}
