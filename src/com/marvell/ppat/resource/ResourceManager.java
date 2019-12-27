package com.marvell.ppat.resource;

import java.util.HashMap;

import com.marvell.ppat.resource.Resource;

public class ResourceManager {

private static HashMap<String, Resource> resourceMap = new HashMap<String, Resource>();
	
	public static Resource getResource(String key){	
			return resourceMap.get(key);
	}
	
	public static void addResource(String key, Resource resource) {
		resourceMap.put(key, resource);
	}
	
	public static void removeResource(String key) {
		resourceMap.remove(key);
	}
	
	public static void cleanup() {
		for (Resource c : resourceMap.values()) {
//			if(c != null){
//				c.cleanup();
//			}
			c.cleanup();
		}
	}
}
