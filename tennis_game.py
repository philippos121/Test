#!/usr/bin/env python3
"""
DOS-style Tennis Game (Pong)
Controls:
- Player 1 (Left): W/S keys to move up/down
- Player 2 (Right): UP/DOWN arrow keys to move up/down
- Q to quit
"""

import curses
import time
import random

class TennisGame:
    def __init__(self, stdscr):
        self.stdscr = stdscr
        self.height, self.width = stdscr.getmaxyx()

        # Ball properties
        self.ball_x = self.width // 2
        self.ball_y = self.height // 2
        self.ball_dx = random.choice([-1, 1])
        self.ball_dy = random.choice([-1, 1])

        # Paddle properties
        self.paddle_height = 5
        self.paddle1_y = self.height // 2 - self.paddle_height // 2
        self.paddle2_y = self.height // 2 - self.paddle_height // 2
        self.paddle1_x = 2
        self.paddle2_x = self.width - 3

        # Scores
        self.score1 = 0
        self.score2 = 0

        # Game settings
        curses.curs_set(0)  # Hide cursor
        self.stdscr.nodelay(1)  # Non-blocking input
        self.stdscr.timeout(50)  # Refresh rate

    def draw_paddle(self, x, y):
        """Draw a paddle at position x, y"""
        for i in range(self.paddle_height):
            if 0 <= y + i < self.height:
                self.stdscr.addch(y + i, x, '█')

    def draw_ball(self):
        """Draw the ball"""
        if 0 <= self.ball_y < self.height and 0 <= self.ball_x < self.width:
            self.stdscr.addch(self.ball_y, self.ball_x, 'O')

    def draw_net(self):
        """Draw the center net"""
        for y in range(0, self.height, 2):
            self.stdscr.addch(y, self.width // 2, '|')

    def draw_score(self):
        """Draw the score"""
        score_text = f"{self.score1} : {self.score2}"
        x = self.width // 2 - len(score_text) // 2
        self.stdscr.addstr(0, x, score_text)

    def update_ball(self):
        """Update ball position and handle collisions"""
        # Move ball
        self.ball_x += self.ball_dx
        self.ball_y += self.ball_dy

        # Top/bottom wall collision
        if self.ball_y <= 0 or self.ball_y >= self.height - 1:
            self.ball_dy *= -1

        # Paddle collision - Player 1
        if (self.ball_x == self.paddle1_x + 1 and
            self.paddle1_y <= self.ball_y < self.paddle1_y + self.paddle_height):
            self.ball_dx = abs(self.ball_dx)
            # Add some variation to the bounce
            if self.ball_y == self.paddle1_y or self.ball_y == self.paddle1_y + self.paddle_height - 1:
                self.ball_dy = random.choice([-1, 1])

        # Paddle collision - Player 2
        if (self.ball_x == self.paddle2_x - 1 and
            self.paddle2_y <= self.ball_y < self.paddle2_y + self.paddle_height):
            self.ball_dx = -abs(self.ball_dx)
            # Add some variation to the bounce
            if self.ball_y == self.paddle2_y or self.ball_y == self.paddle2_y + self.paddle_height - 1:
                self.ball_dy = random.choice([-1, 1])

        # Score points
        if self.ball_x <= 0:
            self.score2 += 1
            self.reset_ball()
        elif self.ball_x >= self.width - 1:
            self.score1 += 1
            self.reset_ball()

    def reset_ball(self):
        """Reset ball to center"""
        self.ball_x = self.width // 2
        self.ball_y = self.height // 2
        self.ball_dx = random.choice([-1, 1])
        self.ball_dy = random.choice([-1, 1])

    def handle_input(self, key):
        """Handle keyboard input"""
        # Player 1 controls (W/S)
        if key == ord('w') or key == ord('W'):
            self.paddle1_y = max(1, self.paddle1_y - 1)
        elif key == ord('s') or key == ord('S'):
            self.paddle1_y = min(self.height - self.paddle_height - 1, self.paddle1_y + 1)

        # Player 2 controls (Arrow keys)
        elif key == curses.KEY_UP:
            self.paddle2_y = max(1, self.paddle2_y - 1)
        elif key == curses.KEY_DOWN:
            self.paddle2_y = min(self.height - self.paddle_height - 1, self.paddle2_y + 1)

        # Quit
        elif key == ord('q') or key == ord('Q'):
            return False

        return True

    def draw_instructions(self):
        """Draw game instructions at the bottom"""
        instructions = "Player 1: W/S | Player 2: UP/DOWN | Q: Quit"
        if len(instructions) < self.width:
            self.stdscr.addstr(self.height - 1,
                             (self.width - len(instructions)) // 2,
                             instructions)

    def run(self):
        """Main game loop"""
        while True:
            # Clear screen
            self.stdscr.clear()

            # Draw everything
            self.draw_net()
            self.draw_paddle(self.paddle1_x, self.paddle1_y)
            self.draw_paddle(self.paddle2_x, self.paddle2_y)
            self.draw_ball()
            self.draw_score()
            self.draw_instructions()

            # Update ball
            self.update_ball()

            # Handle input
            try:
                key = self.stdscr.getch()
                if key != -1:
                    if not self.handle_input(key):
                        break
            except:
                pass

            # Refresh screen
            self.stdscr.refresh()

def main(stdscr):
    game = TennisGame(stdscr)
    game.run()

if __name__ == "__main__":
    curses.wrapper(main)
