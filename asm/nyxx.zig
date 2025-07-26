const std = @import("std");

pub fn main() !void {
    var file = try std.fs.cwd().createFile("nyxx.nes", .{});
    defer file.close();
    var writer = file.writer();

    // iNES header
    try writer.writeAll(&[_]u8{ 0x4E, 0x45, 0x53, 0x1A }); // "NES" magic
    try writer.writeByte(0x02); // PRG-ROM banks
    try writer.writeByte(0x01); // CHR-ROM banks
    try writer.writeByte(0x01); // Vertical mirroring
    try writer.writeByte(0x00); // No mapper
    try writer.writeAll(&[_]u8{0} ** 8); // Padding

    // PRG-ROM (32KB)
    var prg_rom = [_]u8{0} ** (16384 * 2);
    
    // Reset vector code at 0x8000
    var code_offset: usize = 0;
    
    // Reset routine
    prg_rom[code_offset] = 0x78; code_offset += 1; // sei
    prg_rom[code_offset] = 0xA2; code_offset += 1; // ldx #$ff
    prg_rom[code_offset] = 0xFF; code_offset += 1;
    prg_rom[code_offset] = 0x9A; code_offset += 1; // txs
    
    // Turn off screen
    prg_rom[code_offset] = 0xA9; code_offset += 1; // lda #$00
    prg_rom[code_offset] = 0x00; code_offset += 1;
    prg_rom[code_offset] = 0x8D; code_offset += 1; // sta $2000
    prg_rom[code_offset] = 0x00; code_offset += 1;
    prg_rom[code_offset] = 0x20; code_offset += 1;
    prg_rom[code_offset] = 0x8D; code_offset += 1; // sta $2001
    prg_rom[code_offset] = 0x01; code_offset += 1;
    prg_rom[code_offset] = 0x20; code_offset += 1;
    
    // Set palette address
    prg_rom[code_offset] = 0xA9; code_offset += 1; // lda #$3f
    prg_rom[code_offset] = 0x3F; code_offset += 1;
    prg_rom[code_offset] = 0x8D; code_offset += 1; // sta $2006
    prg_rom[code_offset] = 0x06; code_offset += 1;
    prg_rom[code_offset] = 0x20; code_offset += 1;
    prg_rom[code_offset] = 0xA9; code_offset += 1; // lda #$00
    prg_rom[code_offset] = 0x00; code_offset += 1;
    prg_rom[code_offset] = 0x8D; code_offset += 1; // sta $2006
    prg_rom[code_offset] = 0x06; code_offset += 1;
    prg_rom[code_offset] = 0x20; code_offset += 1;
    
    // Copy palette
    prg_rom[code_offset] = 0xA2; code_offset += 1; // ldx #$00
    prg_rom[code_offset] = 0x00; code_offset += 1;
    prg_rom[code_offset] = 0xA0; code_offset += 1; // ldy #$10
    prg_rom[code_offset] = 0x10; code_offset += 1;
    
    const copypal_loop = code_offset;
    prg_rom[code_offset] = 0xBD; code_offset += 1; // lda palettes,x
    prg_rom[code_offset] = 0x00; code_offset += 1; // Low byte (will be set later)
    prg_rom[code_offset] = 0x80; code_offset += 1; // High byte (will be set later)
    prg_rom[code_offset] = 0x8D; code_offset += 1; // sta $2007
    prg_rom[code_offset] = 0x07; code_offset += 1;
    prg_rom[code_offset] = 0x20; code_offset += 1;
    prg_rom[code_offset] = 0xE8; code_offset += 1; // inx
    prg_rom[code_offset] = 0x88; code_offset += 1; // dey
    prg_rom[code_offset] = 0xD0; code_offset += 1; // bne copypal
    const offset1: i8 = @intCast(@as(i32, @intCast(copypal_loop)) - @as(i32, @intCast(code_offset)) - 1);
    prg_rom[code_offset] = @bitCast(offset1); code_offset += 1;
    
    // Set nametable address for text
    prg_rom[code_offset] = 0xA9; code_offset += 1; // lda #$21
    prg_rom[code_offset] = 0x21; code_offset += 1;
    prg_rom[code_offset] = 0x8D; code_offset += 1; // sta $2006
    prg_rom[code_offset] = 0x06; code_offset += 1;
    prg_rom[code_offset] = 0x20; code_offset += 1;
    prg_rom[code_offset] = 0xA9; code_offset += 1; // lda #$c9
    prg_rom[code_offset] = 0xC9; code_offset += 1;
    prg_rom[code_offset] = 0x8D; code_offset += 1; // sta $2006
    prg_rom[code_offset] = 0x06; code_offset += 1;
    prg_rom[code_offset] = 0x20; code_offset += 1;
    
    // Copy text
    prg_rom[code_offset] = 0xA2; code_offset += 1; // ldx #$00
    prg_rom[code_offset] = 0x00; code_offset += 1;
    prg_rom[code_offset] = 0xA0; code_offset += 1; // ldy #$0c (12 chars for "Hello, Nyxx!")
    prg_rom[code_offset] = 0x0C; code_offset += 1;
    
    const copymap_loop = code_offset;
    prg_rom[code_offset] = 0xBD; code_offset += 1; // lda string,x
    prg_rom[code_offset] = 0x00; code_offset += 1; // Low byte (will be set later)
    prg_rom[code_offset] = 0x80; code_offset += 1; // High byte (will be set later)
    prg_rom[code_offset] = 0x8D; code_offset += 1; // sta $2007
    prg_rom[code_offset] = 0x07; code_offset += 1;
    prg_rom[code_offset] = 0x20; code_offset += 1;
    prg_rom[code_offset] = 0xE8; code_offset += 1; // inx
    prg_rom[code_offset] = 0x88; code_offset += 1; // dey
    prg_rom[code_offset] = 0xD0; code_offset += 1; // bne copymap
    const offset2: i8 = @intCast(@as(i32, @intCast(copymap_loop)) - @as(i32, @intCast(code_offset)) - 1);
    prg_rom[code_offset] = @bitCast(offset2); code_offset += 1;
    
    // Set scroll
    prg_rom[code_offset] = 0xA9; code_offset += 1; // lda #$00
    prg_rom[code_offset] = 0x00; code_offset += 1;
    prg_rom[code_offset] = 0x8D; code_offset += 1; // sta $2005
    prg_rom[code_offset] = 0x05; code_offset += 1;
    prg_rom[code_offset] = 0x20; code_offset += 1;
    prg_rom[code_offset] = 0x8D; code_offset += 1; // sta $2005
    prg_rom[code_offset] = 0x05; code_offset += 1;
    prg_rom[code_offset] = 0x20; code_offset += 1;
    
    // Turn on screen
    prg_rom[code_offset] = 0xA9; code_offset += 1; // lda #$08
    prg_rom[code_offset] = 0x08; code_offset += 1;
    prg_rom[code_offset] = 0x8D; code_offset += 1; // sta $2000
    prg_rom[code_offset] = 0x00; code_offset += 1;
    prg_rom[code_offset] = 0x20; code_offset += 1;
    prg_rom[code_offset] = 0xA9; code_offset += 1; // lda #$1e
    prg_rom[code_offset] = 0x1E; code_offset += 1;
    prg_rom[code_offset] = 0x8D; code_offset += 1; // sta $2001
    prg_rom[code_offset] = 0x01; code_offset += 1;
    prg_rom[code_offset] = 0x20; code_offset += 1;
    
    // Infinite loop
    const mainloop = code_offset;
    prg_rom[code_offset] = 0x4C; code_offset += 1; // jmp mainloop
    prg_rom[code_offset] = @intCast(mainloop & 0xFF); code_offset += 1;
    prg_rom[code_offset] = @intCast((mainloop >> 8) | 0x80); code_offset += 1;
    
    // Data section
    const palettes_addr = code_offset + 0x8000;
    const string_addr = palettes_addr + 16;
    
    // Fix addresses in code
    prg_rom[copypal_loop + 1] = @intCast(palettes_addr & 0xFF);
    prg_rom[copypal_loop + 2] = @intCast(palettes_addr >> 8);
    prg_rom[copymap_loop + 1] = @intCast(string_addr & 0xFF);
    prg_rom[copymap_loop + 2] = @intCast(string_addr >> 8);
    
    // Palette data
    const palettes = [_]u8{
        0x0F, 0x00, 0x10, 0x20,
        0x0F, 0x06, 0x16, 0x26,
        0x0F, 0x08, 0x18, 0x28,
        0x0F, 0x0A, 0x1A, 0x2A,
    };
    @memcpy(prg_rom[code_offset..code_offset + 16], &palettes);
    code_offset += 16;
    
    // String data "HELLO, NYXX!"
    const string = "HELLO, NYXX!";
    @memcpy(prg_rom[code_offset..code_offset + string.len], string);
    
    // Reset vector at end of PRG-ROM
    prg_rom[0x7FFA] = 0x00; // NMI vector (unused)
    prg_rom[0x7FFB] = 0x80;
    prg_rom[0x7FFC] = 0x00; // Reset vector points to 0x8000
    prg_rom[0x7FFD] = 0x80;
    prg_rom[0x7FFE] = 0x00; // IRQ vector (unused)
    prg_rom[0x7FFF] = 0x80;
    
    try writer.writeAll(&prg_rom);
    
    // CHR-ROM - read from character.chr file
    const chr_file = try std.fs.cwd().openFile("character.chr", .{});
    defer chr_file.close();
    
    const chr_rom = try chr_file.readToEndAlloc(std.heap.page_allocator, 8192);
    defer std.heap.page_allocator.free(chr_rom);
    
    try writer.writeAll(chr_rom);
    
    std.debug.print("Generated nyxx.nes with 'HELLO, NYXX!' message\n", .{});
}