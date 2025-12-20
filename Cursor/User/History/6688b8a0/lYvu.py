from manim import *

class Intro(Scene):
    def construct(self):
        # Title
        title = Text("Welcome to Manim", font_size=48)
        subtitle = Text("Mathematical Animations in Python", font_size=28)
        subtitle.next_to(title, DOWN)

        # Shapes
        circle = Circle(color=BLUE).shift(LEFT * 2)
        square = Square(color=GREEN).shift(RIGHT * 2)

        # Animations
        self.play(Write(title))
        self.play(FadeIn(subtitle))
        self.wait(1)

        self.play(Create(circle), Create(square))
        self.wait(1)

        self.play(
            circle.animate.shift(RIGHT * 2),
            square.animate.shift(LEFT * 2),
            run_time=2
        )

        self.play(FadeOut(title), FadeOut(subtitle))
        self.wait(1)
