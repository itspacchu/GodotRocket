#ifndef GD_PID_HPP
#define GD_PID_HPP

#include<Godot.hpp>
#include<Node.hpp>

namespace godot{
    class PID : public Node{
        GODOT_CLASS(PID, Node)
    private:
        String _data;
        int _kp;
        int _ki;
        int _kd;
        int _max;
        int _min;
        int _previous_error;
        int _integral;
        int _previous_time;

    public:
        static void _register_methods();
        void _init();
        void _process(float delta);
        void set_kp(int kp);
        void set_ki(int ki);
        void set_kd(int kd);
        void set_pid(int kp, int ki, int kd);
    };
}
#endif