//
//  LlamaCppBridge.h
//  MiniLLM
//
//  Objective-C++ bridge to llama.cpp for Swift interoperability
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LlamaCppBridge : NSObject

/// Load a GGUF model from file path
/// @param path Absolute path to .gguf model file
/// @param contextSize Context window size (default: 2048)
/// @param threads Number of threads (default: 4)
/// @return Opaque pointer to llama context, or NULL on failure
+ (nullable void *)loadModelWithPath:(NSString *)path
                         contextSize:(int)contextSize
                             threads:(int)threads;

/// Generate text completion synchronously
/// @param context Llama context from loadModelWithPath
/// @param prompt Input text prompt
/// @param maxTokens Maximum tokens to generate
/// @param temperature Sampling temperature (0.0-2.0)
/// @param topP Nucleus sampling parameter
/// @return Generated text
+ (NSString *)generateWithContext:(void *)context
                           prompt:(NSString *)prompt
                        maxTokens:(int)maxTokens
                      temperature:(float)temperature
                             topP:(float)topP;

/// Generate text with streaming callback
/// @param context Llama context
/// @param prompt Input text prompt
/// @param maxTokens Maximum tokens to generate
/// @param temperature Sampling temperature
/// @param topP Nucleus sampling parameter
/// @param callback Block called for each generated token
+ (void)generateStreamWithContext:(void *)context
                           prompt:(NSString *)prompt
                        maxTokens:(int)maxTokens
                      temperature:(float)temperature
                             topP:(float)topP
                         callback:(void (^)(NSString *token))callback;

/// Free model and context
/// @param context Context to free
+ (void)freeModel:(void *)context;

/// Get model information
/// @param context Model context
/// @return Dictionary with model metadata
+ (NSDictionary *)getModelInfo:(void *)context;

@end

NS_ASSUME_NONNULL_END
