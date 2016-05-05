//
//  CryptoBuff.h
//  ABCryptorDemo
//
//  Created by BoWang on 16/5/3.
//  Copyright © 2016年 BoWang. All rights reserved.
//

#import <Foundation/Foundation.h>
#pragma mark - NSData(CryptoBuff)
@interface NSData(CryptoBuff)
#pragma mark  MD5,SHA1,SHA2
-(NSData *)buffCryptoMD5;
-(void)buffCryptoMD5Async:(void(^)(NSData *cryptoData))cryptoBlock;
-(NSData *)buffCryptoSHA1;
-(void)buffCryptoSHA1Async:(void(^)(NSData *cryptoData))cryptoBlock;
-(NSData *)buffCryptoSHA224;
-(void)buffCryptoSHA224Async:(void(^)(NSData *cryptoData))cryptoBlock;
-(NSData *)buffCryptoSHA256 ;
-(void)buffCryptoSHA256Async:(void(^)(NSData *cryptoData))cryptoBlock;
-(NSData *)buffCryptoSHA384;
-(void)buffCryptoSHA384Async:(void(^)(NSData *cryptoData))cryptoBlock;
-(NSData *)buffCryptoSHA512;
-(void)buffCryptoSHA512Async:(void(^)(NSData *cryptoData))cryptoBlock;
@end

#pragma mark - NSString(CryptoBuff)

@interface NSString(CryptoBuff)
#pragma mark  MD5,SHA1,SHA2
-(NSString *)buffCryptoMD5;
-(void)buffCryptoMD5Async:(void(^)(NSString *cryptoString))cryptoBlock;
-(NSString *)buffCryptoSHA1;
-(void)buffCryptoSHA1Async:(void(^)(NSString *cryptoString))cryptoBlock;
-(NSString *)buffCryptoSHA224;
-(void)buffCryptoSHA224Async:(void(^)(NSString *cryptoString))cryptoBlock;
-(NSString *)buffCryptoSHA256;
-(void)buffCryptoSHA256Async:(void(^)(NSString *cryptoString))cryptoBlock;
-(NSString *)buffCryptoSHA384;
-(void)buffCryptoSHA384Async:(void(^)(NSString *cryptoString))cryptoBlock;
-(NSString *)buffCryptoSHA512;
-(void)buffCryptoSHA512Async:(void(^)(NSString *cryptoString))cryptoBlock;
@end


