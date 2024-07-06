import time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import rerender_templates

class Watcher:
    DIRECTORY_TO_WATCH = [
        "project_root/config.json",
        "project_root/templates/",
        "project_root/images/"
    ]

    def __init__(self):
        self.observer = Observer()

    def run(self):
        event_handler = Handler()
        for directory in self.DIRECTORY_TO_WATCH:
            self.observer.schedule(event_handler, directory, recursive=True)
        self.observer.start()
        try:
            while True:
                time.sleep(5)
        except KeyboardInterrupt:
            self.observer.stop()
        self.observer.join()

class Handler(FileSystemEventHandler):

    @staticmethod
    def on_any_event(event):
        if event.is_directory:
            return None
        elif event.event_type == 'created' or event.event_type == 'modified':
            # Run the rerender script
            print(f"Change detected: {event.src_path}. Re-rendering templates...")
            rerender_templates.rerender_templates()

if __name__ == '__main__':
    w = Watcher()
    w.run()
