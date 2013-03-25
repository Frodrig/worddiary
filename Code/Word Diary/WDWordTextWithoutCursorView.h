//
//  WDWordTextWithoutCursorView.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 20/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDWordTextView.h"

@interface WDWordTextWithoutCursorView : WDWordTextView<NSCopying>

// Nota:
// - Sirve para guardar el texto en modo fantasma. Tengo dudas de si esto en MVC es correcto
@property(nonatomic, strong) NSString *gosthWordText;

- (id)copy;

@end
