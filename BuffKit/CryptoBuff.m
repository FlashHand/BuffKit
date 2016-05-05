//
//  CryptoBuff.m
//  ABCryptoDemo
//
//  Created by BoWang on 16/5/3.
//  Copyright © 2016年 BoWang. All rights reserved.
//

#import "CryptoBuff.h"
#import <CommonCrypto/CommonCrypto.h>
#pragma mark - NSData extension
//MD5
NSData* _buffMD5FromData(NSData *source)
{
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(source.bytes, (CC_LONG)source.length, result);
    NSData *md5=[[NSData alloc] initWithBytes:result length:CC_MD5_DIGEST_LENGTH];
    return md5;
}
//SHA1
NSData *_buffSHA1FromData(NSData *source)
{
    uint8_t result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(source.bytes, (CC_LONG)source.length, result);
    NSData *sha1 = [[NSData alloc] initWithBytes:result length:CC_SHA1_DIGEST_LENGTH];
    return sha1;
}
//SHA224
NSData *_buffSHA224FromData(NSData *source)
{
    uint8_t result[CC_SHA224_DIGEST_LENGTH];
    CC_SHA224(source.bytes, (CC_LONG)source.length, result);
    NSData *sha224 = [[NSData alloc] initWithBytes:result length:CC_SHA224_DIGEST_LENGTH];
    return sha224;
}
NSData *_buffSHA256FromData(NSData *source)
{
    uint8_t result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(source.bytes, (CC_LONG)source.length, result);
    NSData *sha256 = [[NSData alloc] initWithBytes:result length:CC_SHA256_DIGEST_LENGTH];
    return sha256;
}
NSData *_buffSHA384FromData(NSData *source)
{
    uint8_t result[CC_SHA384_DIGEST_LENGTH];
    CC_SHA384(source.bytes, (CC_LONG)source.length, result);
    NSData *sha384 = [[NSData alloc] initWithBytes:result length:CC_SHA384_DIGEST_LENGTH];
    return sha384;
}
NSData *_buffSHA512FromData(NSData *source)
{
    uint8_t result[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(source.bytes, (CC_LONG)source.length, result);
    NSData *sha512 = [[NSData alloc] initWithBytes:result length:CC_SHA512_DIGEST_LENGTH];
    return sha512;
}
@implementation NSData (CryptoBuff)
#pragma mark MD5,SHA1,SHA2,

-(NSData *)buffCryptoMD5
{
    return _buffMD5FromData(self);
}
-(void)buffCryptoMD5Async:(void (^)(NSData *))cryptoBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        cryptoBlock(_buffMD5FromData(self));
    });
}
-(NSData *)buffCryptoSHA1
{
    return _buffSHA1FromData(self);
}
-(void)buffCryptoSHA1Async:(void (^)(NSData *))cryptoBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        cryptoBlock(_buffSHA1FromData(self));
    });
}
-(NSData *)buffCryptoSHA224
{
    return _buffSHA224FromData(self);
}
-(void)buffCryptoSHA224Async:(void (^)(NSData *))cryptoBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        cryptoBlock(_buffSHA224FromData(self));
    });
}
-(NSData *)buffCryptoSHA256
{
    return _buffSHA256FromData(self);
}
-(void)buffCryptoSHA256Async:(void(^)(NSData *cryptoData))cryptoBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        cryptoBlock(_buffSHA256FromData(self));
    });
}
-(NSData *)buffCryptoSHA384
{
    return _buffSHA384FromData(self);
}
-(void)buffCryptoSHA384Async:(void(^)(NSData *cryptoData))cryptoBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        cryptoBlock(_buffSHA384FromData(self));
    });
}
-(NSData *)buffCryptoSHA512
{
    return _buffSHA512FromData(self);
}
-(void)buffCryptoSHA512Async:(void(^)(NSData *cryptoData))cryptoBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        cryptoBlock(_buffSHA512FromData(self));
    });
}
@end

#pragma mark - NSString extension
NSString* _buffMD5FromString(NSString *source)
{
    const char *cStr = [source UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    NSString *md5=[NSString stringWithFormat:
                   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   result[0], result[1], result[2], result[3],
                   result[4], result[5], result[6], result[7],
                   result[8], result[9], result[10], result[11],
                   result[12], result[13], result[14], result[15]
                   ];
    return md5;
}
NSString* _buffSHA1FromString(NSString *source)
{
    const char *cstr = [source cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:source.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString *sha1 = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH *2];
    for(int i =0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [sha1 appendFormat:@"%02x", digest[i]];
    }
    return sha1;
}

NSString* _buffSHA224FromString(NSString *source)
{
    const char *cstr = [source cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:source.length];
    uint8_t digest[CC_SHA224_DIGEST_LENGTH];
    CC_SHA224(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString *sha224 = [NSMutableString stringWithCapacity:CC_SHA224_DIGEST_LENGTH *2];
    for(int i =0; i < CC_SHA224_DIGEST_LENGTH; i++) {
        [sha224 appendFormat:@"%02x", digest[i]];
    }
    return sha224;
}
NSString* _buffSHA256FromString(NSString *source)
{
    const char *cstr = [source cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:source.length];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString *sha256 = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH *2];
    for(int i =0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [sha256 appendFormat:@"%02x", digest[i]];
    }
    return sha256;
}
NSString* _buffSHA384FromString(NSString *source)
{
    const char *cstr = [source cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:source.length];
    uint8_t digest[CC_SHA384_DIGEST_LENGTH];
    CC_SHA384(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString *sha384 = [NSMutableString stringWithCapacity:CC_SHA384_DIGEST_LENGTH *2];
    for(int i =0; i < CC_SHA384_DIGEST_LENGTH; i++) {
        [sha384 appendFormat:@"%02x", digest[i]];
    }
    return sha384;
}
NSString* _buffSHA512FromString(NSString *source)
{
    const char *cstr = [source cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:source.length];
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString *sha512 = [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH *2];
    for(int i =0; i < CC_SHA512_DIGEST_LENGTH; i++) {
        [sha512 appendFormat:@"%02x", digest[i]];
    }
    return sha512;
}
@implementation NSString (CryptoBuff)
#pragma mark MD5,SHA1,SHA2,
-(NSString *)buffCryptoMD5
{
    return _buffMD5FromString(self);
}
-(void)buffCryptoMD5Async:(void (^)(NSString *))cryptoBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        cryptoBlock(_buffMD5FromString(self));
    });
}
-(NSString *)buffCryptoSHA1
{
    return _buffSHA1FromString(self);
}
-(void)buffCryptoSHA1Async:(void (^)(NSString *))cryptoBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        cryptoBlock(_buffSHA1FromString(self));
    });
}
-(NSString *)buffCryptoSHA224
{
    return _buffSHA224FromString(self);

}
-(void)buffCryptoSHA224Async:(void(^)(NSString *cryptoString))cryptoBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        cryptoBlock(_buffSHA224FromString(self));
    });
}
-(NSString *)buffCryptoSHA256
{
    return _buffSHA256FromString(self);
}
-(void)buffCryptoSHA256Async:(void(^)(NSString *cryptoString))cryptoBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        cryptoBlock(_buffSHA256FromString(self));
    });
}
-(NSString *)buffCryptoSHA384
{
    return _buffSHA384FromString(self);
}
-(void)buffCryptoSHA384Async:(void(^)(NSString *cryptoString))cryptoBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        cryptoBlock(_buffSHA384FromString(self));
    });
}
-(NSString *)buffCryptoSHA512
{
    return _buffSHA512FromString(self);
}
-(void)buffCryptoSHA512Async:(void(^)(NSString *cryptoString))cryptoBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        cryptoBlock(_buffSHA512FromString(self));
    });
}
@end

