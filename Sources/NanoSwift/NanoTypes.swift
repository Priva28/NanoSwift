//
//  NanoTypes.swift
//  
//
//  Created by Christian Privitelli on 7/3/21.
//

public enum NanoAccountPrefix: String {
    case nano = "nano_"
    case xrb = "xrb_"
    case banano = "ban_"
}

public enum NanoType {
    case nano
    case banano
}

public enum NanoTransactionType: String {
    case send
    case receive
    case open
    case change
    case epoch
}

public enum NanoWorkType {
    case all
    case receive
    case send
}
