// kernel.cpp - 内核核心逻辑（32位保护模式）
#include <stdint.h>

// 显卡文本模式缓冲区（0xB8000，80列×25行，每个字符=ASCII+属性）
#define VIDEO_MEMORY 0xB8000
#define SCREEN_WIDTH 80
#define SCREEN_HEIGHT 25
#define WHITE_ON_BLACK 0x07

// 清屏函数
void clear_screen() {
    uint8_t* vid_mem = (uint8_t*)VIDEO_MEMORY;
    for (int i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT * 2; i += 2) {
        vid_mem[i] = ' ';         // 空格字符
        vid_mem[i+1] = WHITE_ON_BLACK; // 属性
    }
}

// 打印字符串（x,y为坐标，str为字符串）
void print_str(int x, int y, const char* str) {
    uint8_t* vid_mem = (uint8_t*)VIDEO_MEMORY;
    int offset = (y * SCREEN_WIDTH + x) * 2;
    while (*str != '\0') {
        vid_mem[offset] = *str++;
        vid_mem[offset+1] = WHITE_ON_BLACK;
        offset += 2;
    }
}

// 内核主函数（保护模式下执行）
extern "C" void kernel_main() { // extern "C"避免C++名称修饰
    clear_screen();
    print_str(10, 10, "Hello OS from C++!");
    while (1); // 死循环，防止退出
}

