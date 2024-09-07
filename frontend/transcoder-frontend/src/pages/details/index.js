import MediaPlayer from "@/components/player";
import { Tabs } from "flowbite-react";
import CropVideo from "./crop-video";
import GenerateThumbnails from "./generate-thumbnails";
export default function Details() {
    return <div class="h-screen grid grid-cols-1">
        {/* <div className="flex justify-center items-center">
    <MediaPlayer/>
  </div> */}
        <div className="">

            <div class="border-b border-gray-200 dark:border-gray-700 overflow-x-auto">
                <Tabs aria-label="Tabs with underline" variant="fullWidth">
                    <Tabs.Item active title="Ad Break Insertion">
                        This is <span className="font-medium text-gray-800 dark:text-white">Profile tab's associated content</span>.
                        Clicking another tab will toggle the visibility of this one for the next. The tab JavaScript swaps classes to
                        control the content visibility and styling.
                    </Tabs.Item>
                    <Tabs.Item title="Crop Video">
                        <CropVideo/>
                    </Tabs.Item>
                    <Tabs.Item title="Concatenation">
                        This is <span className="font-medium text-gray-800 dark:text-white">Settings tab's associated content</span>.
                        Clicking another tab will toggle the visibility of this one for the next. The tab JavaScript swaps classes to
                        control the content visibility and styling.
                    </Tabs.Item>
                    <Tabs.Item title="Captions & Subtitles">
                        This is <span className="font-medium text-gray-800 dark:text-white">Contacts tab's associated content</span>.
                        Clicking another tab will toggle the visibility of this one for the next. The tab JavaScript swaps classes to
                        control the content visibility and styling.
                    </Tabs.Item>
                    <Tabs.Item title="Generate Thumbnails">
                        <GenerateThumbnails/>
                    </Tabs.Item>
                    <Tabs.Item title="Overlay Creation">
                        This is <span className="font-medium text-gray-800 dark:text-white">Contacts tab's associated content</span>.
                        Clicking another tab will toggle the visibility of this one for the next. The tab JavaScript swaps classes to
                        control the content visibility and styling.
                    </Tabs.Item>
                </Tabs>
            </div>

        </div>
    </div>
}