//
//  CryptoBuff.h
//
//  Created by BoWang(r4l.xyz) on 16/5/3.
//  Copyright © 2016年 BoWang(r4l.xyz). All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSStringEncoding  const BuffDefaultStringEncoding;
#pragma mark 支持的CCMode
typedef NS_ENUM(NSInteger, BuffCryptoMode) {
    BuffCryptoModeECB = 1, //kCCModeECB
    BuffCryptoModeCBC = 2, //kCCModeCBC
    BuffCryptoModeCFB = 3, //kCCModeCFB
    BuffCryptoModeCTR = 4, //kCCModeCTR
    BuffCryptoModeOFB = 7, //kCCModeOFB
    BuffCryptoModeCFB8 = 10,//kCCModeCFB8
};
typedef NS_ENUM(NSInteger, BuffCryptoAlgorithm) {
    BuffCryptoAlgorithmAES = 1,
    BuffCryptoAlgorithmDES = 2,
    BuffCryptoAlgorithm3DES = 3,
    BuffCryptoAlgorithmBLOWFISH = 4,
};
#pragma mark - NSData(CryptoBuff)

@interface NSData (CryptoBuff)
#pragma mark  MD5,SHA1,SHA2

- (NSData *)bfCryptoMD5;

- (void)bfCryptoMD5Async:(void (^)(NSData *cryptoData))cryptoBlock;

- (NSData *)bfCryptoSHA1;

- (void)bfCryptoSHA1Async:(void (^)(NSData *cryptoData))cryptoBlock;

- (NSData *)bfCryptoSHA224;

- (void)bfCryptoSHA224Async:(void (^)(NSData *cryptoData))cryptoBlock;

- (NSData *)bfCryptoSHA256;

- (void)bfCryptoSHA256Async:(void (^)(NSData *cryptoData))cryptoBlock;

- (NSData *)bfCryptoSHA384;

- (void)bfCryptoSHA384Async:(void (^)(NSData *cryptoData))cryptoBlock;

- (NSData *)bfCryptoSHA512;

- (void)bfCryptoSHA512Async:(void (^)(NSData *cryptoData))cryptoBlock;

#pragma mark AES

/**
 *  对NSData进行AES加密
 *
 *  @param mode         加密模式：ECB,CBC,CFB,CTR,OFB,CFB8
 *  @param iv           Initialization vector，使用UTF8编码进行加密，ECB下无效
 *  @param key          密钥，使用UTF8编码进行加密
 *  @param cryptoBlock  加密完成后回调，出错则返回nil
 */

- (void)bfCryptoAESEncodeWithMode:(BuffCryptoMode)mode iv:(NSString *)iv key:(NSString *)key completion:(void (^)(NSData *cryptoData))cryptoBlock;
- (void)bfCryptoAESBytesEncodeWithMode:(BuffCryptoMode)mode iv:(NSData *)iv key:(NSData *)key completion:(void (^)(NSData *cryptoData))cryptoBlock;

/**
 *  对NSData进行AES解密
 *
 *  @param mode        加密模式：ECB,CBC,CFB,CTR,OFB,CFB8
 *  @param iv          Initialization vector，使用UTF8编码进行解密，ECB下无效
 *  @param key         密钥，使用UTF8编码进行解密
 *  @param cryptoBlock 解密完成后回调，出错则返回nil
 */
- (void)bfCryptoAESDecodeWithMode:(BuffCryptoMode)mode iv:(NSString *)iv key:(NSString *)key completion:(void (^)(NSData *cryptoData))cryptoBlock;
- (void)bfCryptoAESBytesDecodeWithMode:(BuffCryptoMode)mode iv:(NSData *)iv key:(NSData *)key completion:(void (^)(NSData *cryptoData))cryptoBlock;

//参数同上
#pragma mark DES

- (void)bfCryptoDESEncodeWithMode:(BuffCryptoMode)mode iv:(NSString *)iv key:(NSString *)key completion:(void (^)(NSData *cryptoData))cryptoBlock;
- (void)bfCryptoDESBytesEncodeWithMode:(BuffCryptoMode)mode iv:(NSData *)iv key:(NSData *)key completion:(void (^)(NSData *cryptoData))cryptoBlock;

- (void)bfCryptoDESDecodeWithMode:(BuffCryptoMode)mode iv:(NSString *)iv key:(NSString *)key completion:(void (^)(NSData *cryptoData))cryptoBlock;
- (void)bfCryptoDESBytesDecodeWithMode:(BuffCryptoMode)mode iv:(NSData *)iv key:(NSData *)key completion:(void (^)(NSData *cryptoData))cryptoBlock;

#pragma mark 3DES

- (void)bfCrypto3DESEncodeWithMode:(BuffCryptoMode)mode iv:(NSString *)iv key:(NSString *)key completion:(void (^)(NSData *cryptoData))cryptoBlock;
- (void)bfCrypto3DESBytesEncodeWithMode:(BuffCryptoMode)mode iv:(NSData *)iv key:(NSData *)key completion:(void (^)(NSData *cryptoData))cryptoBlock;

- (void)bfCrypto3DESDecodeWithMode:(BuffCryptoMode)mode iv:(NSData *)iv key:(NSData *)key completion:(void (^)(NSData *cryptoData))cryptoBlock;
- (void)bfCrypto3DESBytesDecodeWithMode:(BuffCryptoMode)mode iv:(NSString *)iv key:(NSString *)key completion:(void (^)(NSData *cryptoData))cryptoBlock;


#pragma mark Blowfish

- (void)bfCryptoBlowfishEncodeWithMode:(BuffCryptoMode)mode iv:(NSString *)iv key:(NSString *)key completion:(void (^)(NSData *cryptoData))cryptoBlock;
- (void)bfCryptoBlowfishBytesEncodeWithMode:(BuffCryptoMode)mode iv:(NSData *)iv key:(NSData *)key completion:(void (^)(NSData *cryptoData))cryptoBlock;

- (void)bfCryptoBlowfishDecodeWithMode:(BuffCryptoMode)mode iv:(NSString *)iv key:(NSString *)key completion:(void (^)(NSData *cryptoData))cryptoBlock;
- (void)bfCryptoBlowfishBytesDecodeWithMode:(BuffCryptoMode)mode iv:(NSData *)iv key:(NSData *)key completion:(void (^)(NSData *cryptoData))cryptoBlock;


@end

#pragma mark - NSString(CryptoBuff)

@interface NSString (CryptoBuff)
#pragma mark  MD5,SHA1,SHA2

- (NSString *)bfCryptoMD5;

- (void)bfCryptoMD5Async:(void (^)(NSString *cryptoString))cryptoBlock;

- (NSString *)bfCryptoSHA1;

- (void)bfCryptoSHA1Async:(void (^)(NSString *cryptoString))cryptoBlock;

- (NSString *)bfCryptoSHA224;

- (void)bfCryptoSHA224Async:(void (^)(NSString *cryptoString))cryptoBlock;

- (NSString *)bfCryptoSHA256;

- (void)bfCryptoSHA256Async:(void (^)(NSString *cryptoString))cryptoBlock;

- (NSString *)bfCryptoSHA384;

- (void)bfCryptoSHA384Async:(void (^)(NSString *cryptoString))cryptoBlock;

- (NSString *)bfCryptoSHA512;

- (void)bfCryptoSHA512Async:(void (^)(NSString *cryptoString))cryptoBlock;
@end

@interface CryptoBuff : NSObject
@end

